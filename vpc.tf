module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.0.1"

  #### Create a vpc 
  create_vpc           = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  name                 = "moses-vpc"
  tags                 = local.default_tags

  #### Create subnets public and private subnets, along with 2 nat gateway across availability zones for the private subnets
  public_subnets       = ["10.0.10.0/24", "10.0.20.0/24"]
  public_subnet_names  = ["Public_Subnet1", " Public_Subnet2"]
  private_subnets      = ["10.0.100.0/24", "10.0.200.0/24"]
  private_subnet_names = ["Private_Subnet1", "Private_Subnet2"]

  ## Internet gateway for public subnets (named as its created by default based on the module).
  igw_tags = merge(
    local.default_tags,
    {
      Name = "IGW1"
    }
  )

  ### enable nat gateway for outbound internet access from private subnets
  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  azs                    = ["us-east-1a", "us-east-1b"]
  nat_gateway_tags = merge(
    local.default_tags,
    {
      Name = "NATGW"
    }
  )

  nat_eip_tags = merge(
    local.default_tags,
    {
      Name = "NAT-EIP"
    }
  )




  ## tag public route table and private route tables
  public_route_table_tags = merge(
    local.default_tags,
    {
      Name = "Public_RT"
    }
  )

  private_route_table_tags = merge(
    local.default_tags,
    {
      Name = "Private_RT"
    }
  )
}


