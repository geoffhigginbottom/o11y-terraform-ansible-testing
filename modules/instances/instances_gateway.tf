# resource "aws_network_interface" "eni1" {
#   count            = var.gateway_count
#   # subnet_id        = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
#   subnet_id        = "var.public_subnet_ids.[0]"
#   private_ips      = ["172.34.1.10"]
# }

# resource "aws_network_interface" "eni1" {
#   # count            = var.gateway_count
#   subnet_id        = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
#   private_ips      = ["172.34.1.10"]
# }

resource "aws_instance" "gateway" {
  count                     = var.gateway_count
  ami                       = var.ubuntu_ami
  instance_type             = var.gateway_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }
  # network_interface {
  #   device_index            = 0
  #   network_interface_id    = "aws_network_interface.eni1[count.index].id"
  #   # network_interface_id    = "aws_network_interface.eni1"
  # }
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  tags = {
    Name = lower(join("_",[var.environment, "gateway", count.index + 1]))
    Environment = lower(var.environment)
    splunkit_environment_type = "non-prd"
    splunkit_data_classification = "public"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      # "sudo apt-get upgrade -y",
    ]
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "gateway_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.gateway.*.tags.Name,
    aws_instance.gateway.*.public_ip,
  )
}