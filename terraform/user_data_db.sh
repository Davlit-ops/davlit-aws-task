#!/bin/bash
apt-get update -y
apt-get install -y mysql-server

# Start service
systemctl start mysql
systemctl enable mysql

# Initial DB setup
mysql -e "CREATE DATABASE eschool;"
mysql -e "CREATE USER '${db_username}'@'%' IDENTIFIED BY '${db_password}';" # terraform.tfvars
mysql -e "GRANT ALL PRIVILEGES ON eschool.* TO '${db_username}'@'%';" # terraform.tfvars
mysql -e "FLUSH PRIVILEGES;"

# Allow MySQL to listen on all interfaces
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
systemctl restart mysql
