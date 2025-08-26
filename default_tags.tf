locals {
  default_tags = {
    Owner       = "Moses Muwanguzi"
    Environment = "Production"
    Project     = "Terraform Training"
    CostCenter  = "IT"
    year        = "2025 to 2066"
    Environment = "prod"
    Terraform   = "true"
    ModuleUse   = "yes"
  }
}

locals {
  nat_gateway_tags = {
    "us-east-1a" = merge(local.default_tags, { Name = "NATGW1" })
    "us-east-1b" = merge(local.default_tags, { Name = "NATGW2" })
  }
}
