provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "win2016base" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "windows_server" {
  ami           = "${data.aws_ami.win2016base.id}"
  instance_type = "t2.medium"
  key_name      = "simon-instratus"

  user_data = "${file("powershell_user_data.txt")}"

  tags {
    Name = "collector.instratus.ca"
    app = "thor"
  }
}

data "aws_route53_zone" "instratus_zone" {
  name         = "instratus.ca."
}

resource "aws_route53_record" "thor" {
  zone_id = "${data.aws_route53_zone.instratus_zone.zone_id}"
  name    = "collector.instratus.ca"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.windows_server.public_ip}"]
}
