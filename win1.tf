variable "endpoint-ip-win1" {
  default = "10.100.20.10"
}

variable "admin-username-win1" {
  default = "RTCAdmin"
}

variable "admin-password-win1" {
  default = "wOFVYKYlk2"
}

variable "join-domain-win1" {
  default = false
}

variable "endpoint_hostname-win1" {
  default = "win1"
}

# AWS AMI for Windows Server
data "aws_ami" "win1" {
  most_recent = true

  filter {
    name   = "name"
    #values = ["Windows_Server-2019-English-Full-Base-*"]
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  owners = ["801119661308"] # Amazon
}

# EC2 Instance
resource "aws_instance" "win1" {
  ami           = data.aws_ami.win1.id
  instance_type = "t2.micro"
  key_name	= module.key_pair.key_pair_name
  subnet_id     = aws_subnet.user_subnet.id
  associate_public_ip_address = true
  user_data	= data.template_file.ps_template_win1.rendered
  vpc_security_group_ids = [
    aws_security_group.operator_windows.id
  ]

  root_block_device {
    volume_size           = 30
  }

  tags = {
    "Name" = "win1"
  }
  depends_on = [
    # reserved for later
  ]
}

data "template_file" "ps_template_win1" {
  template = file("${path.module}/files/windows/bootstrap-win.ps1.tpl")

  vars  = {
    hostname                  = "win1"
    join_domain               = var.join-domain-win1 ? 1 : 0
    install_sysmon            = true ? 1 : 0
    install_red               = true ? 1 : 0
    install_ghosts            = false ? 1 : 0
    install_prelude           = true ? 1 : 0
    auto_logon_domain_user    = false ? 1 : 0
    dc_ip                     = "" 
    endpoint_ad_user          = "" 
    endpoint_ad_password      = "" 
    winrm_username            = "" 
    winrm_password            = "" 
    admin_username            = var.admin-username-win1
    admin_password            = var.admin-password-win1
    ad_domain                 = "rtc.local"
    script_files              = join(",", local.script_files)
    windows_msi               = "" 
    vclient_config            = "" 
    winlogbeat_zip            = "" 
    winlogbeat_config         = "" 
    sysmon_config             = local.sysmon_config 
    sysmon_zip                = local.sysmon_zip 
    s3_bucket                 = "${aws_s3_bucket.staging.id}"
    region                    = var.region
  }
}

resource "local_file" "debug-bootstrap-script-win1" {
  # For inspecting the rendered powershell script as it is loaded onto endpoint 
  content = data.template_file.ps_template_win1.rendered
  filename = "${path.module}/output/windows/bootstrap-${var.endpoint_hostname-win1}.ps1"
}

output "windows_endpoint_details_win1" {
  value = <<EOS
-------------------------
Virtual Machine ${aws_instance.win1.tags["Name"]}
-------------------------
Instance ID: ${aws_instance.win1.id}
Computer Name:  ${aws_instance.win1.tags["Name"]}
Private IP: ${var.endpoint-ip-win1}
Public IP:  ${aws_instance.win1.public_ip}
local Admin:  ${var.admin-username-win1}
local password: ${var.admin-password-win1}

EOS
}
