### Generate Inventory file for Ansible ###
resource "local_file" "mysql_hosts" {
  content = templatefile("${path.module}/templates/mysql_hosts",
    {
      mysql_servers = aws_instance.mysql.*.public_ip
    }
  )
  filename = "${path.module}/mysql_hosts"
}

resource "null_resource" "mysql_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.mysql.*.public_ip) # will trigger ansible whenever there is a change to the list of ips for mysql servers 
    run_mysql_ansible = var.force_run_mysql_ansible ? "${timestamp()}" : null # will trigger ansible if var.force_run_mysql_ansible is set to true - located in terraform.tfvars
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/mysql_hosts ${path.module}/mysql.yml"
  }
}