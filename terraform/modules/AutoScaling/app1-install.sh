#!/bin/bash 
yum update -y 
sudo yum install ruby -y 
sudo yum install wget -y 
wget https://aws-codedeploy-us-east-2.s3.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
amazon-linux-extras install nginx1.12
nginx -v
systemctl start nginx
systemctl enable nginx
chmod 2775 /usr/share/nginx/html 
find /usr/share/nginx/html -type d -exec chmod 2775 {} \;
find /usr/share/nginx/html -type f -exec chmod 0664 {} \;
echo "<h3> Hi, I am Frank </h3>" > /usr/share/nginx/html/index.html