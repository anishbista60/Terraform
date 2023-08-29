provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}
module "my-app-subnet"{
  source = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  avalibilty_zone  = var.avalibilty_zone
  env_prefix =var.env_prefix
  vpc_id = aws_vpc.my_vpc.id
}

 resource "aws_route_table_association" "my_rta" {
   subnet_id = module.my-app-subnet.subnet.id
   route_table_id = module.my-app-subnet.route_table.id

 }
 module "my-app-server"{
  source = "./modules/webserver"
  vpc_id = aws_vpc.my_vpc.id
  subnet_id = module.my-app-subnet.subnet.id
  public_key_location= var.public_key_location
  private_key_location= var.private_key_location
  my_ip = var.my_ip
  instance_type = var.instance_type
  avalibilty_zone = var.avalibilty_zone
  env_prefix= var.env_prefix
}

output "aws_public_ip" {
  value = module.my-app-server.aws-instance
}
 
 