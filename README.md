# AWS Infrastructure & eSchool Web Application Deployment

## 📂 Project Structure

```text
davlit-aws-task/
├── setup_iam.sh            # Script for initial IAM provisioning
├── terraform/
│   ├── main.tf             # Core infrastructure (EC2, SG, Networking)
│   ├── variables.tf        # Configuration variables
│   ├── outputs.tf          # IP addresses and resource IDs
│   └── providers.tf        # AWS Provider configuration
├── app_configs/
│   ├── db_setup.sql        # Database initialization script
│   └── eschool.service     # Systemd unit for the Java application
└── README.md
```

## Flow

### 1. Environment Setup
   Copy keys in terraform.tfvars
   ```bash
   ./setup_iam.sh
   ```
   Create ssh-key
   ```bash
   cd terraform
   ssh-keygen ... vlad-key.pem
   ```
### 2. Infrastructure Provisioning
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### 3. Database Layer
   bind-address need change 
   ```bash
   sudo apt update && sudo apt install -y mysql-server
   sudo vim /etc/mysql/mysql.conf.d/mysqld.cnf
   sudo systemctl restart mysql
   sudo mysql < db_setup.sql # copy from db_setup.sql
   ```

### 4. Application Layer
   comment this file ScheduleControllerIntegrationTest.java
   change spring.datasource.url/spring.datasource.username/spring.datasource.password
   ```bash
   sudo apt update && sudo apt install -y openjdk-8-jdk maven git
   git clone https://github.com/yurkovskiy/eSchool
   vim src/test/java/academy/softserve/eschool/controller/ScheduleControllerIntegrationTest.java
   vim src/main/resources/application.properties
   mvn clean
   mvn install -DskipTests
   java -jar target/eschool.jar
   ```
   skip tests for dodging freezes))
### 5. Service Automation
   eschool.service add to automate
   ```bash
   sudo vim /etc/systemd/system/eschool.service
   sudo systemctl daemon-reload
   sudo systemctl enable eschool
   sudo systemctl start eschool
   ```
