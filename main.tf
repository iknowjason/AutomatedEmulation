variable "region" {
  default = "us-east-2"
}

# Random string for resources
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false 
}

locals {
  rs = "${random_string.suffix.id}"
}

output "aws_region" {
  value   = var.region
}

resource "tls_private_key" "operator" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name   = "operator-${local.rs}"
  public_key = tls_private_key.operator.public_key_openssh
}

# write ssh key to file
resource "local_file" "ssh_key" {
    content  = tls_private_key.operator.private_key_pem
    filename = "${path.module}/ssh_key.pem"
    file_permission = "0700"
}