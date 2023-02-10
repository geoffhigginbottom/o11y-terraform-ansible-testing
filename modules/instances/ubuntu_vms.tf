resource "aws_instance" "ubuntu" {
  count                     = var.ubuntu_count
  ami                       = var.ubuntu_ami
  instance_type             = var.ubuntu_instance_type
  subnet_id                 = element(var.public_subnet_ids, count.index)
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
    Name = lower(join("-",[var.environment,element(var.ubuntu_ids, count.index)]))
    Environment = lower(var.environment)
  }
 
  # provisioner "file" {
  #   source      = "${path.module}/scripts/update_splunk_otel_collector.sh"
  #   destination = "/tmp/update_splunk_otel_collector.sh"
  # }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/127.0.0.1.*/127.0.0.1 ${self.tags.Name}.local ${self.tags.Name} localhost/' /etc/hosts",
      "sudo hostnamectl set-hostname ${self.tags.Name}",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      "sudo mkdir /media/data",
      "sudo echo 'type=83' | sudo sfdisk /dev/xvdg",
      "sudo mkfs.ext4 /dev/xvdg1",
      "sudo mount /dev/xvdg1 /media/data",

      # "TOKEN=${var.access_token}",
      # "REALM=${var.realm}",
  
    ## Install Otel Agent
      # "sudo curl -sSL https://dl.signalfx.com/splunk-otel-collector.sh > /tmp/splunk-otel-collector.sh",
      # "sudo sh /tmp/splunk-otel-collector.sh --realm ${var.realm}  -- ${var.access_token} --mode agent",
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

output "ubuntu_details" {
  value =  formatlist(
    "%s, %s", 
    aws_instance.ubuntu.*.tags.Name,
    aws_instance.ubuntu.*.public_ip,
  )
}