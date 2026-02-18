# AWS Infrastructure & eSchool Web Application Deployment

## 📂 Project Structure

```text
davlit-aws-task/
├── setup_iam.sh            # Script for initial IAM provisioning
├── terraform/
│   ├── main.tf             # # IaC: EC2, Security Groups, Key Pairs
│   ├── variables.tf        # Input definitions (sensitive data handled)
│   ├── outputs.tf          # Connection endpoints (App IP & DB Private IP)
│   └── providers.tf        # AWS Provider configuration
│   ├── user_data_app.sh     # Automation: Java 8, Maven, SWAP, App Setup
│   └── user_data_db.sh      # Automation: MySQL 8, Security & DB Init
└── README.md
```
## Prerequisites
Create terraform/terraform.tfvars and paste the following:
```bash
# AWS Credentials
aws_access_key  = "YOUR_ACCESS_KEY_HERE"
aws_secret_key  = "YOUR_SECRET_KEY_HERE"

# Database Secrets
db_username     = "your_db_user"
db_password     = "your_secure_pass"

# SSH Key Configuration
key_name        = "your_key_name"
public_key_path = "your_public_key_path"
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
   ssh-keygen -t rsa -b 2048 -f <YOUR_KEY_NAME>.pem
   ```
### 2. Infrastructure Provisioning
   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

## 🛠 Automation Details (Under the Hood)

### 3. Database Layer
**Configured automatically via `user_data_db.sh`**
* **Automated Installation:** Full setup of MySQL Server without manual intervention.
* **Network Fix:** `bind-address` updated to `0.0.0.0` to allow private connections from the App Server.
* **Security:** `allowPublicKeyRetrieval=true` enabled to ensure compatibility with MySQL 8 authentication drivers.

### 4. Application Layer
**Configured automatically via `user_data_app.sh`**
* **Performance Fix:** Created **2GB SWAP** file to prevent system freezing on `t3.micro` instances during memory-intensive Maven builds.
* **Legacy Support:** Forced installation of **OpenJDK 8** (strictly required by the eSchool application).
* **Build Process:**
  * Clones the repository.
  * Configures `application.properties` with the correct **DB Private IP**.
  * Runs `mvn install -DskipTests` (tests are skipped to speed up deployment and avoid memory freezes).

### 5. Service Automation
**Systemd Integration**
* **Unit File:** `eschool.service` is automatically generated and placed in `/etc/systemd/system/`.
* **Reliability:** The application is enabled to start on boot and configured to **restart automatically** in case of failure.
