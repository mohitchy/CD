terraform {
  backend "s3" {
    bucket  = "mohitterraform"
    key  = "terraform/state"
    region = "us-east-1"
#   access_key = "XXXXXXXXXXXXXXXXXXXXXX"
#   secret_key = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "mohitami" {
  most_recent      = true
  owners           = ["self"]
  filter {
    name   = "name"
    values = ["mohitchy1-ubuntu-*"]
   }
 }

resource "aws_instance" "mohitawsserver" {
  ami = "ami-0b16724fe8e66e4ec"
  key_name = "mohit-cicd"
  instance_type = "t2.micro"

  tags = {
    Name = "Mohit-Ubuntu-Server"
    Env = "Dev"
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > /etc/ansible/hosts"
  }
 
provisioner "remote-exec" {
    inline = [
     "touch /tmp/mohit"
     ]
 connection {
    type     = "ssh"
    user     = "ubuntu"
    insecure = "true"
    private_key = "${file("/tmp/mohit-cicd.pem")}"
    host     =  aws_instance.mohitawsserver.public_ip
  }
}
}

output "myawsserver-ip" {
  value = "${aws_instance.mohitawsserver.public_ip}"
}
