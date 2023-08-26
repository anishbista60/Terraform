#!/bin/bash
sudo apt-get update 
sudo apt install docker.io -y
sudo systemctl start docker
sudo usermod -aG docker ubuntu 
sudo docker pull nginx:latest
sudo docker run -d -p 8080:8080 nginx:latest