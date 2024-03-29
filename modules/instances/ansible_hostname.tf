### Generate Inventory file for Ansible ###
resource "local_file" "hostname_hosts" {
  content = templatefile("${path.module}/templates/hostname_hosts.tftpl",
    {
      mysql_servers = aws_instance.mysql.*.public_ip
      ubuntu_servers = aws_instance.ubuntu.*.public_ip
      rocky_servers = aws_instance.rocky.*.public_ip
      access_token = var.access_token
      realm = var.realm
      prefix = lower(var.environment)
    }
  )
  filename = "${path.module}/hostname_hosts"
}

resource "null_resource" "hostname_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.mysql.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for mysql servers 
    ubuntu_servers = join(",", aws_instance.ubuntu.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for ubuntu servers
    rocky_servers = join(",", aws_instance.rocky.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for rocky servers
    force_run_ansible_hostname = var.force_run_ansible_hostname? "${timestamp()}" : null # will trigger ansible if var.force_run_ansible_hostname is 'true' - located in terraform.tfvars
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/hostname_hosts ${path.module}/ansible_role_hostname.yaml"
    # command = var.force_run_ansible_hostname?"ansible-playbook -i ${path.module}/hostname_hosts ${path.module}/ansible_role_hostname.yaml":"echo Skipping Run"
  }

  # depends_on = [ null_resource.otel_agent_hosts ]
}