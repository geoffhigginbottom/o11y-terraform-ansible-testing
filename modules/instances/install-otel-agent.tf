### Generate Inventory file for Ansible ###
resource "local_file" "otel_agent_hosts" {
  content = templatefile("${path.module}/templates/otel_agent_hosts",
    {
      mysql_servers = aws_instance.mysql.*.public_ip
      ubuntu_servers = aws_instance.ubuntu.*.public_ip
    }
  )
  filename = "${path.module}/otel_agent_hosts"
}

resource "null_resource" "otel_agent_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.mysql.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for mysql servers 
    ubuntu_servers = join(",", aws_instance.ubuntu.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for ubuntu servers 
    force_run_ansible_install_otel_agent = var.force_run_ansible_install_otel_agent ? "${timestamp()}" : null # will trigger ansible if var.force_run_ansible_install_otel_agent is set to true - located in terraform.tfvars
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/otel_agent_hosts ${path.module}/otel-agent.yml --extra-vars 'realm=${var.realm} accesstoken=${var.access_token} galaxy_otel=${var.galaxy_otel}'"
  }
}