### Generate Inventory file for Ansible
resource "local_file" "mysql_hosts" {
  content = templatefile("${path.module}/templates/mysql_hosts",
    {
      mysql_servers = aws_instance.ubuntu.*.public_ip
    }
  )
  filename = "${path.module}/mysql_hosts"
}

resource "null_resource" "mysql_hosts" {
  
  triggers = {
    mysql_servers = join(",", aws_instance.ubuntu.*.public_ip)
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${path.module}/mysql_hosts ${path.module}/mysql.yml"
  }
}