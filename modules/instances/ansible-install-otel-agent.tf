### Generate Inventory file for Ansible ###
resource "local_file" "otel_agent_hosts" {
  content = templatefile("${path.module}/templates/otel_agent_hosts.tftpl",
    {
      mysql_servers = aws_instance.mysql.*.public_ip
      ubuntu_servers = aws_instance.ubuntu.*.public_ip
      windows_servers = aws_instance.windows_server.*.public_ip
      windows_server_administrator_pwd = var.windows_server_administrator_pwd
      access_token = var.access_token
      realm = var.realm
    }
  )
  filename = "${path.module}/otel_agent_hosts"
}

resource "null_resource" "otel_agent_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.mysql.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for mysql servers 
    ubuntu_servers = join(",", aws_instance.ubuntu.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for ubuntu servers
    windows_servers = join(",", aws_instance.windows_server.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for windows servers 
    force_run_ansible_install_otel_agent = var.force_run_ansible_install_otel_agent ? "${timestamp()}" : null # will trigger ansible if var.force_run_ansible_install_otel_agent is set to true - located in terraform.tfvars
  }

### Triggers the ansible role otel-agent to install the otel agent on hosts using either ansible-galaxy or a local playbook version depending en the setting of 'galaxy_otel' in terafrom.tfvars

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/otel_agent_hosts ${path.module}/ansible_role_otel-agent.yaml --extra-vars 'realm=${var.realm} accesstoken=${var.access_token} galaxy_otel=${var.galaxy_otel}'"
  }
}
