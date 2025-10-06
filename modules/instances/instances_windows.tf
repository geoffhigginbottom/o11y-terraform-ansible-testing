resource "aws_instance" "windows_server" {
  count                     = var.windows_server_count
  ami                       = var.windows_server_ami
  instance_type             = var.windows_server_instance_type
  subnet_id                 = "${var.public_subnet_ids[ count.index % length(var.public_subnet_ids) ]}"
  key_name                  = var.key_name
  vpc_security_group_ids    = [aws_security_group.instances_sg.id]

  # user_data = <<EOF
  # <powershell>

  #   Get-LocalUser -Name "Administrator" | Set-LocalUser -Password (ConvertTo-SecureString -AsPlainText "${var.windows_server_administrator_pwd}" -Force)

  #   Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0
  #   Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' -name IsInstalled -Value 0

  #   Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC" -RemoteAddress Any

  #   # Enable WinRM
  #   winrm quickconfig -q
  #   winrm set winrm/config/service/auth @{Basic="true"}
  #   winrm set winrm/config/service @{AllowUnencrypted="true"}
  #   winrm set winrm/config/winrs @{MaxMemoryPerShellMB="1024"}

  #   # Allow WinRM inbound on port 5985
  #   netsh advfirewall firewall add rule name="WinRM 5985" dir=in action=allow protocol=TCP localport=5985

  #   # Make sure WinRM starts automatically
  #   Set-Service -Name winrm -StartupType Automatic
  #   Start-Service winrm

  #   # Optional: log for debugging
  #   New-Item -Path "C:\\temp" -ItemType Directory -Force
  #   "WinRM configured by user_data at $(Get-Date)" | Out-File "C:\\temp\\winrm_setup.txt" -Encoding utf8
    
  # </powershell>
  # EOF

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
