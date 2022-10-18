#!/bin/bash
#Update server and install dependencies
echo "Installing dependencies"
sudo apt update && sudo apt upgrade -y
sudo apt install apache2
sudo systemctl start apache
sudo systemctl enable apache2
sudo apt install -y php php-{common,mysql,xml,xmlrpc,curl,gd,imagick,cli,dev,imap,mbstring,opcache,soap,zip,intl} -y

#Install wordpress
echo "Downloading and configuring wordpress"
sudo apt install wget unzip -y 
wget https://wordpress.org/latest.zip
sudo unzip latest.zip
sudo mv wordpress/ /var/www/html/
sudo rm latest.zip
sudo chown www-data:www-data -R /var/www/html/wordpress/
sudo chmod -R 755 /var/www/html/wordpress/


#CONFIGURE APACHE
echo "configure" 
sudo mv /home/ubuntu/wordpress.conf /etc/apache2/sites-available/wordpress.conf
#Enable virtual host
sudo a2ensite wordpress.conf
#Enable rewrite module
sudo a2enmod rewrite
#Disable the default Apache test page
sudo a2dissite 000-default.conf
#Restart the Apache webserver to apply the changes:
sudo systemctl restart apache2
