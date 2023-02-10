### Enable/Disable Modules - Values are set in quantity.auto.tfvars ###
variable "instances_enabled" {
  default = []
}

### Instance Count Variables ###
variable "ubuntu_count" {
  default = {}
}
variable "ubuntu_ids" {
  default = []
}
variable "mysql_count" {
  default = {}
}
variable "mysql_ids" {
  default = []
}

### AWS Variables ###
# variable "profile" {
#   default = []
# }
variable "aws_access_key_id" {
  default = []
}
variable "aws_secret_access_key" {
  default = []
}
variable "vpc_name" {
  default = []
}
variable "vpc_cidr_block" {
  default = []
}
variable "subnet_count" {
  default = []
}
variable "key_name" {
  default = []
}
variable "private_key_path" {
  default = []
}
variable "ubuntu_instance_type" {
  default = []
}
variable "mysql_instance_type" {
  default = []
}

variable "region" {
  description = "Select region (1:eu-west-1, 2:eu-west-3, 3:eu-central-1, 4:us-east-1, 5:us-east-2, 6:us-west-1, 7:us-west-2, 8:ap-southeast-1, 9:ap-southeast-2, 10:sa-east-1 )"
}
variable "aws_region" {
  description = "Provide the desired region"
  default = {
    "1"  = "eu-west-1"
    "2"  = "eu-west-3"
    "3"  = "eu-central-1"
    "4"  = "us-east-1"
    "5"  = "us-east-2"
    "6"  = "us-west-1"
    "7"  = "us-west-2"
    "8"  = "ap-southeast-1"
    "9"  = "ap-southeast-2"
    "10" = "sa-east-1"
  }
}

## Ubuntu AMI ##
data "aws_ami" "latest-ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # This is the owner id of Canonical who owns the official aws ubuntu images

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

### Splunk IM/APM Variables ###
variable "environment" {
    default = []
}
variable "access_token" {
    default = []
}
variable "realm" {
    default = []
}


### Ansible Variables ###
variable "force_run_mysql_ansible" {
    default = false
}
variable "force_run_ansible_install_otel_agent" {
    default = false
}
variable "galaxy_otel" {
    default = "yes"
}
