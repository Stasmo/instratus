provider "aws" {
  region = "us-west-2"
}

data "aws_eip" "ftp_ip" {
  public_ip = "34.216.54.55"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ftp_server" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  key_name      = "simon-instratus"

  tags {
    Name = "ftp.instratus.ca"
  }
}

resource "aws_eip_association" "ftp_eip" {
  instance_id   = "${aws_instance.ftp_server.id}"
  allocation_id = "${data.aws_eip.ftp_ip.id}"
}
