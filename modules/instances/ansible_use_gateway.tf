### Generate Inventory file for Ansible ###
resource "local_file" "use_gateway_hosts" {
  content = templatefile("${path.module}/templates/use_gateway_hosts.tftpl",
    {
      ubuntu_servers = aws_instance.ubuntu.*.public_ip
      rocky_servers = aws_instance.rocky.*.public_ip
      windows_servers = aws_instance.windows_server.*.public_ip
      windows_server_administrator_pwd = var.windows_server_administrator_pwd
      prefix = lower(var.environment)
      splunk_gw_url = aws_instance.gateway.0.private_ip
    }
  )
  filename = "${path.module}/use_gateway_hosts"
}

resource "null_resource" "use_gateway_hosts" {
  
  triggers = {
    ubuntu_servers = join(",", aws_instance.ubuntu.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for ubuntu servers
    rocky_servers = join(",", aws_instance.rocky.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for rocky servers
    windows_servers = join(",", aws_instance.windows_server.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for windows servers 
    force_run_ansible_use_gateway = var.force_run_ansible_use_gateway? "${timestamp()}" : null # will trigger ansible if var.force_run_ansible_use_gateway is 'true' - located in terraform.tfvars
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/use_gateway_hosts ${path.module}/ansible_role_use_gateway.yaml"
  }

  depends_on = [
    null_resource.otel_agent_hosts,
    aws_instance.gateway
  ]
}