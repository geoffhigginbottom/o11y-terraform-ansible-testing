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
variable "mysql_instance_type" {
  default = []
}
variable "ubuntu_ami" {
  default = []
}
variable "ubuntu_count" {
  default = []
}
variable "mysql_count" {
  default = []
}
## Windows Vars
variable "windows_server_instance_type" {
  default = []
}
variable "windows_server_administrator_pwd" {
  default = []
}
variable "windows_server_count" {
  default = {}
}
variable "windows_server_ami" {
  default = {}
}


### Ansible Variables ###
variable "mysql_servers" {
  default = []
}
variable "force_run_mysql_ansible" {
  default = []
}
variable "force_run_ansible_install_otel_agent" {
  default = []
}
variable "force_run_ansible_hostname" {
  default = []
}
variable "galaxy_otel" {
  default = []
}
variable "mysql_root_password" {
  default = []
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