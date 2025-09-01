##############################
# AUTO SCALING GROUP
##############################
module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.1"

  name                = "web-asg"
  instance_name       = "web-instance"
  key_name            = "moses2025"
  image_id            = "ami-0360c520857e3138f"
  user_data           = filebase64("user_data.sh")
  instance_type       = "t2.micro"
  vpc_zone_identifier = module.vpc.private_subnets

  security_groups = [module.security_group_vm.security_group_id]

  availability_zone_distribution = {
    capacity_distribution_strategy = "balanced-only"
  }

  create_iam_instance_profile = true
  iam_instance_profile_name   = "my-ec2-instance-profile"
  iam_role_name               = "ec2_role"
  iam_role_policies = {
    ssm_managed_instance_core = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    S3READONLY                = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }

  autoscaling_group_tags = merge(
    local.default_tags,
    { Name = "web-asg" }
  )

  health_check_type         = "EC2"
  health_check_grace_period = 300

  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = 10
        volume_type           = "gp3"
        delete_on_termination = false
      }
    }
  ]
}

##############################
# APPLICATION LOAD BALANCER
##############################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.17.0"

  name                     = "my-alb"
  internal                 = false
  default_port             = 443
  default_protocol         = "HTTPS"
  subnets                  = module.vpc.public_subnets
  security_groups          = [module.security_group.security_group_id]
  enable_deletion_protection = false
  enable_http2             = true
  vpc_id                   = module.vpc.vpc_id
  create_security_group     = false
  ip_address_type           = "ipv4"
}
############################## 
# TARGET GROUP AND LISTENER
##############################

resource "aws_lb_target_group" "frontend" {
  name     = "frontend2025"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = module.vpc.vpc_id

## Health Check for the Target Group which will check the health of the instances in the Auto Scaling Group om port 443
  health_check {
    protocol            = "HTTPS"
    port                = 443
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-299"
  }

  tags = {
    Environment = "production"
  }
}


resource "aws_lb_listener" "frontendlistner" {
  load_balancer_arn = module.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-east-1:711387106973:certificate/0303d743-b2bb-4d09-baed-05e059839ff5"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}


### Attach the ALB Target Group to the Auto Scaling Group
resource "aws_autoscaling_attachment" "asg_alb_attachment" {
  autoscaling_group_name = module.autoscaling.autoscaling_group_name
  lb_target_group_arn    = aws_lb_target_group.frontend.arn
}
