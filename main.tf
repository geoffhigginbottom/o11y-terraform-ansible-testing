# AWS Auth Configuration
provider "aws" {
  region     = lookup(var.aws_region, var.region)
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

# provider "signalfx" {
#   auth_token = var.access_token
#   api_url    = var.api_url
# }


module "vpc" {
  source         = "./modules/vpc"
  vpc_name       = var.environment
  vpc_cidr_block = var.vpc_cidr_block
  subnet_count   = var.subnet_count
  region         = lookup(var.aws_region, var.region)
  environment    = var.environment
}

module "instances" {
  source                           = "./modules/instances"
  count                            = var.instances_enabled ? 1 : 0
#   access_token                     = var.access_token
#   api_url                          = var.api_url
#   realm                            = var.realm
  environment                      = var.environment
  region                           = lookup(var.aws_region, var.region)
  vpc_id                           = module.vpc.vpc_id
  vpc_cidr_block                   = var.vpc_cidr_block
  public_subnet_ids                = module.vpc.public_subnet_ids
  key_name                         = var.key_name
  private_key_path                 = var.private_key_path
  ubuntu_instance_type             = var.ubuntu_instance_type
  ubuntu_ami                       = data.aws_ami.latest-ubuntu.id

  ubuntu_count                    = var.ubuntu_count
  ubuntu_ids                      = var.ubuntu_ids
}

### Outputs ###
## Instances Outputs ##
output "Ubuntu_Servers" {
  value = var.instances_enabled ? module.instances.*.ubuntu_details : null
}