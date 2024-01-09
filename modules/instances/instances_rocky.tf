resource "aws_instance" "rocky" {
  count                     = var.rocky_count
  ami                       = var.rocky_ami
  instance_type             = var.rocky_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  root_block_device {
    volume_size = 16
    volume_type = "gp2"
  }
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  tags = {
    Name = lower(join("_",[var.environment, "rocky", count.index + 1]))
    Environment = lower(var.environment)
    splunkit_environment_type = "non-prd"
    splunkit_data_classification = "public"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y"
    ]
  }

  connection {
    host = self.public_ip
    type = "ssh"
    user = "rocky"
    private_key = file(var.private_key_path)
    agent = "true"
  }
}

output "rocky_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.rocky.*.tags.Name,
    aws_instance.rocky.*.public_ip,
  )
}