resource "aws_key_pair" "ssh-key" {
   key_name = "project-key"
   public_key = file(var.public_key_location)
 }
 resource "aws_security_group" "my-sg" { # if you want to use default security group then instead of "aws_security_group" use "aws_default_security_group" 
                                         # Remove the name of security group cause it is already assigned as default and reamining configuration is samename = "my-security-group"
    vpc_id = var.vpc_id

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress{
        from_port = 80
        to_port = 80
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

  resource "aws_instance" "myapp-server" {
   ami = "ami-053b0d53c279acc90"
   instance_type = var.instance_type
   subnet_id= var.subnet_id
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
