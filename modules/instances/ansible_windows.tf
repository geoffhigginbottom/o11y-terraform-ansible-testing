### Generate Inventory file for Ansible ###
resource "local_file" "windows_hosts" {
  content = templatefile("${path.module}/templates/windows_hosts.tftpl",
    {
      windows_servers = aws_instance.windows_server.*.public_ip
    }
  )
  filename = "${path.module}/windows_hosts"
}

resource "null_resource" "windows_hosts" {
  
  triggers = {
    windows_servers = join(",", aws_instance.windows_server.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for windows servers
  }

  # provisioner "local-exec" {
  #   command = "ansible-playbook -i ${path.module}/windows_hosts ${path.module}/windows.yml"
  # }
}
