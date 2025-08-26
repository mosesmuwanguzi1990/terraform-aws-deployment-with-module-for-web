module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "9.0.1"

  ## lAUNCH TEMPLATE AND AUTO SCALING GROUP CONFIGURATION
  name    = "web-asg"
  instance_name = "web-instance"
  key_name = "moses2025"
  image_id = "ami-0360c520857e3138f"
  user_data               = filebase64("user_data.sh")
 security_groups = [module.security_group_vm.security_group_id]
  launch_template_name = "aws_launch_web_template"
  launch_template_version = "$Latest"
  instance_type = "t2.micro"
  #availability_zones = ["us-east-1a", "us-east-1b"]
  availability_zone_distribution = { capacity_disribution_strategy = "balanced" }
  vpc_zone_identifier = module.vpc.private_subnets




  
  ## IAM Role for the EC2 instances in the Auto Scaling Group
  create_iam_instance_profile = true
  iam_instance_profile_name = "my-ec2-instance-profile"
  iam_role_name = "ec2_role"
  iam_role_policies = {
   ssm_managed_instance_core  = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    S3READONLY = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }
  autoscaling_group_tags = merge(
    local.default_tags,
    {
      Name = "web-asg"
    }
  )

  #### Max and min size of the auto scaling group
  health_check_type         = "EC2"
  health_check_grace_period = 300
  desired_capacity = 2
  max_size     = 2
  min_size = 2

  ## Block device mappings
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


### Create an Application Load Balancer to distribute traffic to the EC2 instances in the Auto Scaling Group
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.17.0"
  name               = "my-alb"
  internal           = false
  default_port = 443
  default_protocol = "HTTPS"
  subnets            = module.vpc.public_subnets
  security_groups   = [module.security_group.security_group_id]
  enable_deletion_protection = false
  enable_http2 = true
  #load_balancer_type = "application"
  #minimum_load_balancer_capacity = 1
  vpc_id = module.vpc.vpc_id
  create_security_group = false
  ip_address_type = "ipv4"
  target_groups = [
    {
      name     = "frontend2025"
      port     = 443
      protocol = "HTTPS"
      vpc_id   = module.vpc.vpc_id

      health_check = {
        protocol            = "HTTPS"
        port                = "443"
        path                = "/"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 5
        unhealthy_threshold = 2
        matcher             = "200-299"
      }

      target_type = "instance"
      targets = module.autoscaling.instance_ids
      deregistration_delay = 300


    
    }
  ]
  listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      ssl_policy         = "ELBSecurityPolicy-2016-08"
      certificate_arn    = "arn:aws:acm:us-east-1:711387106973:certificate/0303d743-b2bb-4d09-baed-05e059839ff5"
      default_action_type = "forward"

      
      fixed_response = {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = "404"
      }
    }
  ]

}

