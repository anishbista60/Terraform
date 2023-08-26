provider "aws" {
  region = "us-east-1"
}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avalibilty_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type"{}
variable "public_key_location"{}
variable "private_key_location"{}

resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }

}
resource "aws_subnet" "my_subnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avalibilty_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
  
}
resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block="0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
     tags = {
        Name: "${var.env_prefix}-rtb"
    }
 }

# Instead of creating new route table you can use the default one
# You can configure in the same way as mentioned below
/*
 resource "aws_default_route_table" "main-rtb"{
    default_route_table_id = aws_vpc.my_vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }
        tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

*/

 resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name: "${var.env_prefix}-igw"
    }
   
 }
 
 resource "aws_route_table_association" "my_rta" {
   subnet_id = aws_subnet.my_subnet.id
   route_table_id = aws_route_table.my_route_table.id

 }

 resource "aws_security_group" "my-sg" { # if you want to use default security group then instead of "aws_security_group" use "aws_default_security_group" 
                                         # Remove the name of security group cause it is already assigned as default and reamining configuration is samename = "my-security-group"
     vpc_id = aws_vpc.my_vpc.id

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress{
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks =["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
      Name: "${var.env_prefix}-SG"
    }
 }
 resource "aws_key_pair" "ssh-key" {
   key_name = "project-key"
   public_key = file(var.public_key_location)
 }

 resource "aws_instance" "myapp-server" {
   ami = "ami-053b0d53c279acc90"
   instance_type = var.instance_type
   subnet_id=aws_subnet.my_subnet.id
   vpc_security_group_ids = [aws_security_group.my-sg.id]
   availability_zone = var.avalibilty_zone
   associate_public_ip_address = true

   key_name = aws_key_pair.ssh-key.key_name

   connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key  = file(var.private_key_location)
   }

   provisioner "file" {
    source ="entry-script.sh"
    destination = "/home/ubuntu/entry-script-on-ec2.sh"
  }
  
   provisioner "remote-exec"{
       inline = [ 
      "chmod +x /home/ubuntu/entry-script-on-ec2.sh", 
      "sh /home/ubuntu/entry-script-on-ec2.sh",           
    ]
   }
   provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.text"
     
   }
   
   tags = {
    Name = "${var.env_prefix}-server"
   }
}
output "aws_public_ip" {
  value = aws_instance.myapp-server.public_ip
}
 
 