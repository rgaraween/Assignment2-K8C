
provider "aws" {
  region = "us-east-1"
}


data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


data "terraform_remote_state" "public_subnet" { 
  backend = "s3"
  config = {
    bucket = "assignment2-rgaraween"               
    key    = "dev/networking/terraform.tfstate" 
    region = "us-east-1"                          
  }
}


data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_instance" "my_amazon" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.assignment2.key_name
  subnet_id                   = data.terraform_remote_state.public_subnet.outputs.subnet_id
  vpc_security_group_ids     = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-Amazon-Linux"
    }
  )
}


resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.assignment2.id
  instance_id = aws_instance.my_amazon.id
}




resource "aws_key_pair" "assignment2" {
  key_name   = "assignment2"
  public_key = file("${var.prefix}.pub")
}




resource "aws_ebs_volume" "assignment2" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 40

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-EBS"
    }
  )
}

resource "aws_ecr_repository" "mysql_ecr_repo" {
  name                 = "assignment2-ecr-mysql"
  image_tag_mutability = "MUTABLE"  
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "app_ecr_repo" {
  name                 = "assignment2-ecr-app"
  image_tag_mutability = "MUTABLE"  
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.public_subnet.outputs.vpc_id

  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "8081 from everywhere"
    from_port        = 30000
    to_port          = 30000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-EBS"
    }
  )
}