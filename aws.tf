variable "access_key" {}
variable "secret_access_key" {}

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_access_key}"
  region     = "us-east-1"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "test_vpc"
  }
}

resource "aws_instance" "web" {
  ami                         = "ami-70dad51a"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.ssh.id}"]
  associate_public_ip_address = true
  key_name                    = "dev"
  subnet_id = "${aws_subnet.main.id}"

  tags = {
    Name = "webserver"
  }
}

resource "aws_security_group" "ssh" {
  name        = "ssh"
  description = "ssh connection"
  vpc_id      = "${aws_vpc.test_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 0
  #   to_port = 0
  #   protocol = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
}

resource "aws_subnet" "main" {
  vpc_id     = "${aws_vpc.test_vpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  tags = {
    Name = "main_igw"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.test_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.main.id}"
  route_table_id = "${aws_route_table.r.id}"
}
