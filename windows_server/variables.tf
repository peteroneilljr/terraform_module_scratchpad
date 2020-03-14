variable "subnet_id" {
  
}
variable "key_name" {
  
}
variable "windows_year" {
  
}

variable "user_data" {
  default = ""
  
}
variable "server_name" {
  
}
variable "vpc_id" {
  
}
variable "default_tags" {
  
}
variable "monitoring" {
  default = true
}
variable "get_password_data" {
  default = true
}
variable "associate_public_ip_address" {
  default = true
}
#################
# Data
#################
data "aws_ami" "windows_server" {
  owners = [ "amazon" ]

  filter {
    name   = "name"
    values = [local.windows_search]
  }

  most_recent = true
}

#################
# Locals
#################
locals {
  windows_filters = {
    "2016" = "Windows_Server-2016-English*",
    "2019" = "Windows_Server-2019-English*"
  }
  windows_search = [for i, z in local.windows_filters: z if i == var.windows_year][0]
  user_data = <<USERDATA
<powershell>
# Allow authentication method to be negotiated between server and client
Write-Output "Allow authentication method to be negotiated between server and client"
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "SecurityLayer" -Value "1" -PropertyType DWORD -Force | Out-Null

# Disable NLA for RDP  
Write-Output "Disable NLA for RDP"
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value "0" -PropertyType DWORD -Force | Out-Null

# Install firefox
Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-GB" -Outfile C:\Users\Administrator\Desktop\firefox.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I C:\Users\Administrator\Desktop\firefox.msi /quiet'

# Install SDM Client
Invoke-WebRequest -Uri "https://app.strongdm.com/releases/cli/windows" -Outfile C:\Users\Administrator\Desktop\sdm_installer.exe
Start-Process "C:\Users\Administrator\Desktop\sdm_installer.exe" -ArgumentList "/q" -Wait
</powershell>
<persist>true</persist>
USERDATA
}


