resource "aws_subnet" "my_subnet" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avalibilty_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}


 resource "aws_internet_gateway" "my_igw" {
    vpc_id = var.vpc_id

    tags = {
        Name: "${var.env_prefix}-igw"
    }
   
 }
 
resource "aws_route_table" "my_route_table" {
    vpc_id = var.vpc_id

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
