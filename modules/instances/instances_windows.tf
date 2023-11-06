resource "aws_instance" "windows_server" {
  count                     = var.windows_server_count
  ami                       = var.windows_server_ami
  instance_type             = var.windows_server_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  user_data = <<EOF
  <powershell>

    Get-LocalUser -Name "Administrator" | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText "${var.windows_server_administrator_pwd}" -Force)

    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0
    Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0

    Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any

    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'

  </powershell>
  EOF

  tags = {
    Name = lower(join("_",[var.environment, "windows", count.index + 1]))
    Environment = lower(var.environment)
    splunkit_environment_type = "non-prd"
    splunkit_data_classification = "public"
  }

# This is really just a delaying tactic to force Terraform to wait for Windows Hosts to be ready before trying to initiate Ansible Playbooks via local-exec as remote-exe must be completed first
# Without this remote-exec connection, Terraform will try to initiate Ansible Playbook as soon as Windows Hosts have been deployed, even though they are still 'booting up'
  provisioner "remote-exec" {
    inline = [
      "powershell.exe New-Item C:/Temp/test.txt -type file",
      "powershell.exe Remove-Item C:/Temp/test.txt"
    ]
  }

  connection {
    host = self.public_ip
    type = "winrm"
    user = "Administrator"
    password = var.windows_server_administrator_pwd
    insecure = true
    timeout = "7m"
  }
}

output "windows_details" {
  value =  formatlist(
    "%s, %s, %s", 
    aws_instance.windows_server.*.tags.Name,
    aws_instance.windows_server.*.public_ip,
    aws_instance.windows_server.*.public_dns, 
  )
}
