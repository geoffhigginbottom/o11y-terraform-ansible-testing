resource "aws_instance" "mysql" {
  count                     = var.mysql_count
  ami                       = var.ubuntu_ami
  instance_type             = var.mysql_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }
  ebs_block_device {
    device_name = "/dev/xvdg"
    volume_size = 10
    volume_type = "gp2"
  }
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  tags = {
    Name = lower(join("_",[var.environment, "mysql", count.index + 1]))
    Environment = lower(var.environment)
  }
 
  # provisioner "remote-exec" {
  #   inline = [
  #     # "sudo apt-get update",
  #     # "sudo apt-get upgrade -y",
  #   ]
  # }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "mysql_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.mysql.*.tags.Name,
    aws_instance.mysql.*.public_ip,
  )
}