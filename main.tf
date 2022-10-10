provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "my-first-server" {
  ami           = "ami-08c40ec9ead489470"
  instance_type = "t2.micro"
}
