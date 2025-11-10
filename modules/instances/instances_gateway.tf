resource "aws_instance" "gateway" {
  count                     = var.gateway_count
  ami                       = var.ubuntu_ami
  instance_type             = var.gateway_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  root_block_device {
    volume_size = 16
    volume_type = "gp3"
    encrypted   = true
    delete_on_termination = true

    tags = {
      Name                          = lower(join("-", [var.environment, "gateway", count.index + 1, "root"]))
      splunkit_environment_type     = "non-prd"
      splunkit_data_classification  = "private"
    }
  }

  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  # user_data = file("${path.module}/scripts/userdata.sh")

  tags = {
    Name = lower(join("_",[var.environment, "gateway", count.index + 1]))
    Environment = lower(var.environment)
    splunkit_environment_type = "non-prd"
    splunkit_data_classification = "private"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      # "sudo apt-get upgrade -y",
    ]
  }

  connection {
    host = self.public_ip
    port = 22
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