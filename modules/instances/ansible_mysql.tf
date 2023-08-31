### Generate Inventory file for Ansible ###
resource "local_file" "mysql_hosts" {
  content = templatefile("${path.module}/templates/mysql_hosts.tftpl",
    {
      mysql_servers = aws_instance.mysql.*.public_ip
      mysql_root_password = var.mysql_root_password
      access_token = var.access_token
      realm = var.realm
      prefix = lower(var.environment)
    }
  )
  filename = "${path.module}/mysql_hosts"
}

resource "null_resource" "mysql_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.mysql.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for mysql servers 
    force_run_mysql_ansible = var.force_run_mysql_ansible ? "${timestamp()}" : null # will trigger ansible if var.force_run_mysql_ansible is 'true' - located in terraform.tfvars
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/mysql_hosts ${path.module}/ansible_role_mysql.yaml"
  }

  depends_on = [
    null_resource.otel_agent_hosts,
    aws_instance.mysql
  ]
}