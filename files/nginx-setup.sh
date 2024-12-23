#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras enable nginx1
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
echo "Instance ID: $(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)" > /usr/share/nginx/html/index.html

