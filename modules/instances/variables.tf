### AWS Variables ###
variable "region" {
  default = []
}
variable "vpc_id" {
  default = []
}
variable "vpc_cidr_block" {
  default = []
}
variable "public_subnet_ids" {
  default = []
}
variable "key_name" {
  default = []
}
variable "private_key_path"{
  default = []
}
variable "ubuntu_instance_type" {
  default = []
}
variable "ubuntu_ami" {
  default = []
}
variable "ubuntu_count" {
  default = []
}
variable "ubuntu_ids" {
  default = []
}

### Ansible Variables ###
variable "mysql_servers" {
    default = []
}

### Splunk IM/APM Variables ###
variable "environment" {
  default = []
}