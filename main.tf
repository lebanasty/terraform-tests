provider "aws" {
  region = "us-west-1"
}
resource "aws_launch_configuration" "example" {
  image_id = "ami-066c6938fb715719f"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  tags = {
    Name = "terraform-example"
  }
  lifecycle {
    create_before_destroy = true
  }
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress { 
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  min_size = 2
  max_size = 10
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
}
variable "server_port" {
  description = "traffic port"
  #default = 8080
  type = number
}
output "server_IP" {
  description = "aws public IP address"
  value = aws_instance.example.public_ip
}