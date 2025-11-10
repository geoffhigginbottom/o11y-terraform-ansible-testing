resource "aws_instance" "windows_server" {
  count                     = var.windows_server_count
  ami                       = var.windows_server_ami
  instance_type             = var.windows_server_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  root_block_device {
    volume_size = 80
    volume_type = "gp3"
    encrypted   = true
    delete_on_termination = true

    tags = {
      Name                          = lower(join("-", [var.environment, "windows", count.index + 1, "root"]))
      splunkit_environment_type     = "non-prd"
      splunkit_data_classification  = "private"
    }
  }

  user_data = <<EOF
  <powershell>
  # Set Administrator password
  Get-LocalUser -Name "Administrator" | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText "${var.windows_server_administrator_pwd}" -Force)

  # Disable Active Setup prompts
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -Name IsInstalled -Value 0
  Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -Name IsInstalled -Value 0

  # Enable WinRM service
  winrm quickconfig -q

  # Configure WinRM using WSMan provider
  Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
  Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
  Set-Item -Path WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 1024

  # Delete existing HTTP listener and recreate on all addresses
  winrm delete winrm/config/listener?Address=*+Transport=HTTP
  winrm create winrm/config/listener?Address=*+Transport=HTTP

  # Open firewall for WinRM on all profiles
  New-NetFirewallRule -DisplayName "Allow WinRM HTTP" -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Any

  # Ensure WinRM service starts automatically
  Set-Service -Name winrm -StartupType Automatic
  Start-Service winrm

  # Optional debug log
  New-Item -Path "C:\\temp" -ItemType Directory -Force
  "WinRM fully configured at $(Get-Date)" | Out-File "C:\\temp\\winrm_setup.txt" -Encoding utf8
  </powershell>
  EOF



  tags = {
    Name = lower(join("_",[var.environment, "windows", count.index + 1]))
    Environment = lower(var.environment)
    splunkit_environment_type = "non-prd"
    splunkit_data_classification = "private"
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
    port = 5985
    insecure = true
    timeout = "15m"
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
