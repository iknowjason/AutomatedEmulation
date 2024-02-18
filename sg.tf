# Thanks to @christophetd and his Github.com/Adaz project for this little code
data "http" "firewall_allowed" {
  url = "http://ifconfig.so"
}

locals {
  #src_ip = "${chomp(data.http.firewall_allowed.response_body)}/32"
  src_ip = "0.0.0.0/0" 
}

resource "aws_security_group" "operator" {
  name        = "operator_bas_security_group"
  description = "Allow traffic to BAS"
  vpc_id      = aws_vpc.operator.id 
  ingress {
    from_port   = -1 
    to_port     = -1 
    protocol    = "icmp"
    cidr_blocks = [local.src_ip, var.vpc_cidr]
  }
  ingress {
    from_port   = 9092 
    to_port     = 9092 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr]
  }
  ingress {
    from_port   = 22 
    to_port     = 22 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  ingress {
    from_port   = 443 
    to_port     = 443 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  ingress {
    from_port   = 8080 
    to_port     = 8080 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  ingress {
    from_port   = 8088 
    to_port     = 8088 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  ingress {
    from_port   = 2181 
    to_port     = 2181 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  ingress {
    from_port   = 8888 
    to_port     = 8888 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr]
  }
  ingress {
    from_port   = 8000 
    to_port     = 8000 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip, var.vpc_cidr] 
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "operator_bas_security_group"
  }
}

resource "aws_security_group" "operator_windows" {
  name        = "operator_windows_security_group"
  description = "Allow traffic to Windows"
  vpc_id      = aws_vpc.operator.id 
  ingress {
    from_port   = 3389 
    to_port     = 3389 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip]
  }
  ingress {
    from_port   = 5985 
    to_port     = 5985 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip]
  }
  ingress {
    from_port   = 5986 
    to_port     = 5986 
    protocol    = "tcp"
    cidr_blocks = [local.src_ip]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "operator_windows_security_group"
  }
}
