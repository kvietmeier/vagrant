#!/usr/bin/env bash

# nginx install
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx

# setup firewall
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --reload

# clean /var/www
sudo rm -Rf /var/www

# symlink /var/www => /vagrant
ln -s /vagrant/nginx/www /var/www
sudo chown -R nginx:nginx /var/www
sudo chmod 755 -R /var/www
sudo chmod 644 -R /var/www/index.html

# set up nginx server
sudo cp /vagrant/nginx/nginx.conf /etc/nginx/
sudo chmod 644 /etc/nginx/nginx.conf
sudo systemctl restart nginx
