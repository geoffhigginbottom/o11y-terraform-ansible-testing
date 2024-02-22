### Generate Inventory file for Ansible ###


# resource "local_file" "use_gateway_hosts" {
#   count    = var.gateway_count != 0 ? 1 : 0  # Only create when var.gateway_count is not 0

#   content  = templatefile("${path.module}/templates/use_gateway_hosts.tftpl", {
#     mysql_servers  = aws_instance.mysql.*.public_ip
#     ubuntu_servers = aws_instance.ubuntu.*.public_ip
#     rocky_servers  = aws_instance.rocky.*.public_ip
#     prefix         = lower(var.environment)
#     splunk_gw_url = aws_instance.gateway.0.private_ip
#   }
# )
#   filename = "${path.module}/use_gateway_hosts"
# }

resource "local_file" "use_gateway_hosts" {
  content = templatefile("${path.module}/templates/use_gateway_hosts.tftpl",
    {
      mysql_servers = aws_instance.mysql.*.public_ip
      ubuntu_servers = aws_instance.ubuntu.*.public_ip
      rocky_servers = aws_instance.rocky.*.public_ip
      prefix = lower(var.environment)
      splunk_gw_url = aws_instance.gateway.0.private_ip
    }
  )
  filename = "${path.module}/use_gateway_hosts"
}

resource "null_resource" "use_gateway_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.mysql.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for mysql servers 
    ubuntu_servers = join(",", aws_instance.ubuntu.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for ubuntu servers
    rocky_servers = join(",", aws_instance.rocky.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for rocky servers
    force_run_ansible_use_gateway = var.force_run_ansible_use_gateway? "${timestamp()}" : null # will trigger ansible if var.force_run_ansible_use_gateway is 'true' - located in terraform.tfvars
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/use_gateway_hosts ${path.module}/ansible_role_use_gateway.yaml"
  }

#   provisioner "local-exec" {
#     command = <<-EOT
#       # if [ "${var.gateway_count}" -ne 0 ]; then
#       if [ -n "${var.gateway_count}" ]; then
#         ansible-playbook -i ${path.module}/use_gateway_hosts ${path.module}/ansible_role_use_gateway.yaml
#       else
#         echo "Skipping Ansible playbook execution."
#       fi
#     EOT
#   }


  depends_on = [
    null_resource.otel_agent_hosts,
    aws_instance.gateway
  ]
}