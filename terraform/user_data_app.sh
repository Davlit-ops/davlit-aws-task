#!/bin/bash
# Logging setup
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# FIX: ADD SWAP Prevent crash
# The build process is very resource intensive
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# 1. Install dependencies
apt-get update -y
apt-get install -y software-properties-common
add-apt-repository ppa:openjdk-r/ppa -y 
apt-get update -y
apt-get install -y openjdk-8-jdk maven git

# FIX: FORCE JAVA 8
# Ubuntu 22.04 may default to Java 11+, i get 'javassist NullPointerException'
update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
update-alternatives --set javac /usr/lib/jvm/java-8-openjdk-amd64/bin/javac

# 2. Clone repository
cd /home/ubuntu
git clone https://github.com/yurkovskiy/eSchool.git
chown -R ubuntu:ubuntu eSchool

# 3. Reconfigure application.properties
PROPS_PATH="/home/ubuntu/eSchool/src/main/resources/application.properties"
if [ -f "$PROPS_PATH" ]; then
    # Point to the DB private IP instead of localhost
    sed -i "s/localhost/${db_ip}/g" "$PROPS_PATH"
    
    # Set DB credentials from Terraform variables
    sed -i "s/spring.datasource.username=.*/spring.datasource.username=${db_username}/" "$PROPS_PATH"
    sed -i "s/spring.datasource.password=.*/spring.datasource.password=${db_password}/" "$PROPS_PATH"

    # FIX: MySQL 8 compatibility
    # Append 'allowPublicKeyRetrieval=true' to the connection string inside the $${DATASOURCE_URL:...} block
    sed -i 's/useSSL=false}/useSSL=false\&allowPublicKeyRetrieval=true}/' "$PROPS_PATH"
fi

# Comment the test file as required
TEST_FILE=$(find /home/ubuntu/eSchool -name "ScheduleControllerIntegrationTest.java")
if [ -f "$TEST_FILE" ]; then
    sed -i 's/^/\/\//' "$TEST_FILE" 
fi

# 4. Create Systemd Service
# Using the full path to Java 8 to ensure the service runs on the correct JVM.
cat <<EOF > /etc/systemd/system/eschool.service
[Unit]
Description=eSchool Web Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/eSchool
ExecStart=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java -jar /home/ubuntu/eSchool/target/eschool.jar
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable service to run on boot
systemctl enable eschool.service
