# Created with Operator Lab
# The terraform file that creates the Breach and Attack Simulation Server system
# VECTR, Caldera, and Operator Headless
variable "vectr_port" {
  description = "Default listening port https for VECTR"
  default     = "8081"
}

variable "caldera_port" {
  description = "Default listening port http for Caldera"
  default     = "8888"
}

variable "caldera_port_https" {
  description = "Default listening port https for Caldera"
  default     = "8443"
}

variable "api_key_blue" {
  description = "Caldera api blue key"
  default     = "blueadmin2024"
}

variable "api_key_red" {
  description = "Caldera api red key"
  default     = "redadmin2024"
}

variable "blue_username" {
  description = "Caldera blue username"
  default     = "blue"
}

variable "blue_password" {
  description = "Caldera blue password"
  default     = "Caldera2024"
}

variable "red_username" {
  description = "Caldera red username"
  default     = "red"
}

variable "red_password" {
  description = "Caldera red password"
  default     = "Caldera2024"
}

variable "caldera_admin_username" {
  description = "Caldera admin username"
  default     = "admin"
}

variable "caldera_admin_password" {
  description = "Caldera admin password"
  default     = "Caldera2024"
}

output "public_dns" {
  description = "The public DNS of the vectr server"
  value       = aws_instance.bas_server.public_dns
}

variable "bas_server_instance_type" {
  description = "The AWS instance type to use for servers."
  #default     = "t2.micro"
  default     = "t3a.medium"
}

variable "bas_root_block_device_size" {
  description = "The volume size of the root block device."
  default     =  130 
}

resource "aws_security_group" "bas_ingress" {
  name   = "bas-ingress"
  vpc_id = aws_vpc.operator.id

  # Server port 2222 Caldera 
  ingress {
    from_port       = 2222 
    to_port         = 2222 
    protocol        = "tcp"
    cidr_blocks     = [local.src_ip]
  }

  # Server port Caldera http console
  ingress {
    from_port       = var.caldera_port 
    to_port         = var.caldera_port 
    protocol        = "tcp"
    cidr_blocks     = [local.src_ip]
  }

  # Server port Caldera https console
  ingress {
    from_port       = var.caldera_port_https 
    to_port         = var.caldera_port_https 
    protocol        = "tcp"
    cidr_blocks     = [local.src_ip]
  }

  # Server port 8081 VECTR https console
  ingress {
    from_port       = var.vectr_port 
    to_port         = var.vectr_port 
    protocol        = "tcp"
    cidr_blocks     = [local.src_ip]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bas_ssh_ingress" {
  name   = "bas-ssh-ingress"
  vpc_id = aws_vpc.operator.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.src_ip]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "bas_allow_all_internal" {
  name   = "bas-allow-all-internal"
  vpc_id = aws_vpc.operator.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }
}

data "aws_ami" "bas_server" {
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "bas_server" {
  ami                    = data.aws_ami.bas_server.id
  instance_type          = var.bas_server_instance_type
  subnet_id              = aws_subnet.user_subnet.id
  key_name               = module.key_pair.key_pair_name 
  vpc_security_group_ids = [aws_security_group.bas_ingress.id, aws_security_group.bas_ssh_ingress.id, aws_security_group.bas_allow_all_internal.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.private_key.private_key_pem
    host        = self.public_ip
  }

  tags = {
    "Name" = "bas"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.bas_root_block_device_size
    delete_on_termination = "true"
  }

  user_data = templatefile("files/bas/bootstrap.sh.tpl", {
    s3_bucket                 = "${aws_s3_bucket.staging.id}" 
    region                    = var.region
  })

}

output "BAS_server_details" {
  value = <<CONFIGURATION

-------------
VECTR Console
-------------
https://${aws_instance.bas_server.public_dns}:${var.vectr_port}

VECTR Credentials
-----------------
admin:11_ThisIsTheFirstPassword_11

-------
Caldera Console
-------
https://${aws_instance.bas_server.public_dns}:${var.caldera_port_https}

Caldera Console Credentials
-------------------
${var.blue_username}:${var.blue_password}
${var.red_username}:${var.red_password}
${var.caldera_admin_username}:${var.caldera_admin_password}

API Keys
--------
api_key_blue: ${var.api_key_blue}
api_key_red: ${var.api_key_red}

Caldera API Cheat Sheet 
-----------------------
Get Agents:
curl -k https://${aws_instance.bas_server.public_dns}:${var.caldera_port_https}/api/v2/agents \
  -H 'accept: application/json' -H "KEY:${var.api_key_red}"
--------------
Get Agent's paw (PAW_ID value):
PAW_ID=`curl -k https://${aws_instance.bas_server.public_dns}:${var.caldera_port_https}/api/v2/agents \
  -H 'accept: application/json' -H "KEY:${var.api_key_red}" | jq -r '.[].paw'`
--------------
Access (run an ability against agent based on PAW_ID):
curl -k https://${aws_instance.bas_server.public_dns}:${var.caldera_port_https}/plugin/access/exploit \
  -H 'accept: application/json' -H "KEY:${var.api_key_red}" -H POST \
  -d "{\"paw\":\"$PAW_ID\",\"ability_id\":\"c7ec57cd-933e-42b6-99a4-e852a9e57a33\",\"obfuscator\":\"plain-text\"}"

SSH
---
ssh -i ssh_key.pem ubuntu@${aws_instance.bas_server.public_ip}  

CONFIGURATION
}

resource "aws_s3_object" "caldera_service_config" {
  bucket = aws_s3_bucket.staging.id
  key    = "caldera.service"
  source = "${path.module}/files/bas/caldera.service"
  content_type = "text/plain"
}

resource "aws_s3_object" "caldera_default_yml" {
  bucket = aws_s3_bucket.staging.id
  key    = "default.yml"
  source = local_file.caldera_default_yml.filename
  content_type = "text/plain"

  depends_on = [local_file.caldera_default_yml]
}

resource "aws_s3_object" "vectr_env" {
  bucket = aws_s3_bucket.staging.id
  key    = "vectr_env"
  source = local_file.vectr_env.filename
  content_type = "text/plain"

  depends_on = [local_file.vectr_env]
}

resource "local_file" "caldera_default_yml" {
  content  = data.template_file.caldera_local_yml.rendered
  filename = "${path.module}/output/bas/local.yml"
}

resource "local_file" "vectr_env" {
  content  = data.template_file.vectr_env.rendered
  filename = "${path.module}/output/bas/vectr_env"
}

data "template_file" "caldera_local_yml" {
  template = file("${path.module}/files/bas/local.yml.tpl")

  vars = {
    api_key_blue            = var.api_key_blue 
    api_key_red             = var.api_key_red
    blue_username           = var.blue_username
    blue_password           = var.blue_password
    caldera_admin_username  = var.caldera_admin_username
    caldera_admin_password  = var.caldera_admin_password
    red_username            = var.red_username
    red_password            = var.red_password
    caldera_port            = var.caldera_port
  }
}

data "template_file" "vectr_env" {
  template = file("${path.module}/files/bas/vectr_env.tpl")

  vars = {
    vectr_hostname   = aws_instance.bas_server.public_dns 
    vectr_port       = var.vectr_port
  }
}

data "archive_file" "abilities" {
    type        = "zip"
    source_dir  = "${path.module}/files/bas/abilities"
    output_path = "${path.module}/output/bas/abilities.zip"
}

data "archive_file" "payloads" {
    type        = "zip"
    source_dir  = "${path.module}/files/bas/payloads"
    output_path = "${path.module}/output/bas/payloads.zip"
}

resource "aws_s3_object" "abilities_zip" {
    depends_on = [data.archive_file.abilities]
    
    bucket = aws_s3_bucket.staging.id
    key    = "abilities.zip"
    source = "${data.archive_file.abilities.output_path}"
}

resource "aws_s3_object" "payloads_zip" {
    depends_on = [data.archive_file.payloads]
    
    bucket = aws_s3_bucket.staging.id
    key    = "payloads.zip"
    source = "${data.archive_file.payloads.output_path}"
}
