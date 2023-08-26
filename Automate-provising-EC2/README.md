# Terraform Infrastructure Overview

This Terraform code sets up an AWS infrastructure for deploying an application on an EC2 instance. Below is a summary of the resources and configurations created:

## Resources Created

1. **Provider Configuration**
   - Configures the AWS provider to operate in the "us-east-1" region.

2. **Variables**
   - Variables are used to customize various aspects of the infrastructure, including VPC settings, subnet configuration, instance type, and more.

3. **VPC Resource**
   - Creates an AWS Virtual Private Cloud (VPC) with the specified CIDR block and a name tag.

4. **Subnet Resource**
   - Establishes an AWS subnet within the VPC, defined by the provided CIDR block, availability zone, and name tag.

5. **Internet Gateway Resource**
   - Attaches an internet gateway to the VPC, allowing communication between instances in the VPC and the internet.

6. **Route Table Resource**
   - Creates a custom route table associated with the VPC, including a default route for internet connectivity.

7. **Route Table Association Resource**
   - Associates the custom route table with the previously created subnet, enabling proper routing.

8. **Security Group Resource**
   - Sets up an AWS security group to control inbound and outbound traffic to instances within the VPC.

9. **Key Pair Resource**
   - Generates an AWS key pair for SSH access to instances.

10. **EC2 Instance Resource**
    - Launches an EC2 instance with the specified configuration, including instance type, subnet, security group, and more.
    - Executes a remote provisioner to run commands and scripts within the instance.
    - Executes a local provisioner to create an output file containing the instance's public IP address.

11. **Output**
    - Provides the public IP address of the created EC2 instance for easy access.

## `entry-point.sh` Script

As part of the EC2 instance provisioning, the `entry-point.sh` script is executed within the instance. This script performs the following tasks:

1. Updates package information using `sudo apt-get update`.
2. Installs Docker using `sudo apt install docker.io -y`.
3. Starts the Docker service using `sudo systemctl start docker`.
4. Adds the "ubuntu" user to the Docker group using `sudo usermod -aG docker ubuntu`.
5. Pulls the latest Nginx Docker image using `sudo docker pull nginx:latest`.
6. Runs an Nginx Docker container in detached mode, mapping port 8080 from the host to port 8080 in the container using `sudo docker run -d -p 8080:8080 nginx:latest`.

Please refer to the provided Terraform code for detailed configurations and settings.
