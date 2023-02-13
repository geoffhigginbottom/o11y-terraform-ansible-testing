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
  source                                = "./modules/instances"
  count                                 = var.instances_enabled ? 1 : 0
  access_token                          = var.access_token
  galaxy_otel                           = var.galaxy_otel
  realm                                 = var.realm
  environment                           = var.environment
  region                                = lookup(var.aws_region, var.region)
  vpc_id                                = module.vpc.vpc_id
  vpc_cidr_block                        = var.vpc_cidr_block
  public_subnet_ids                     = module.vpc.public_subnet_ids
  key_name                              = var.key_name
  private_key_path                      = var.private_key_path
  ubuntu_instance_type                  = var.ubuntu_instance_type
  mysql_instance_type                   = var.mysql_instance_type
  ubuntu_ami                            = data.aws_ami.latest-ubuntu.id
  ubuntu_count                          = var.ubuntu_count
  ubuntu_ids                            = var.ubuntu_ids
  mysql_count                           = var.mysql_count
  mysql_ids                             = var.mysql_ids
  windows_server_count                  = var.windows_server_count
  windows_server_ids                    = var.windows_server_ids
  windows_server_administrator_pwd      = var.windows_server_administrator_pwd
  windows_server_instance_type          = var.windows_server_instance_type
  windows_server_ami                    = data.aws_ami.windows-server.id
  force_run_mysql_ansible               = var.force_run_mysql_ansible
  force_run_ansible_install_otel_agent  = var.force_run_ansible_install_otel_agent
}

### Outputs ###
## Instances Outputs ##
output "Ubuntu_Servers" {
  value = var.instances_enabled ? module.instances.*.ubuntu_details : null
}
output "mysql_Servers" {
  value = var.instances_enabled ? module.instances.*.mysql_details : null
}