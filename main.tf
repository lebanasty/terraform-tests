provider "aws" {
  region = "us-west-1"
}
resource "aws_instance" "example" {
  ami = "ami-066c6938fb715719f"
  instance_type = "t2.micro"
  tags = {
    Name = "terraform-example"
  }
}
