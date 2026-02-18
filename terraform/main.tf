# current public IP securing SSH 
data "http" "myip" {
  url = "http://checkip.amazonaws.com/"
}

# Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# SSH key
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("vlad-key.pem.pub")
}

# Security Group: App Server
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "App Server Security Group"

  # SSH: my IP only
  ingress {
    description = "SSH Access from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  # Tomcat: Open to the internet
  ingress {
    description = "Tomcat Web Interface"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group: Database
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "MySQL restricted to App Server"

  # SSH: my IP only
  ingress {
    description = "SSH Access from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  # traffic from the App Server Security Group
  ingress {
    description     = "MySQL from App Server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance: App Server
resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # Pass DB details to the app setup script for auto-configuration
  user_data = templatefile("user_data_app.sh", {
    db_username = var.db_username
    db_password = var.db_password
    db_ip       = aws_instance.db.private_ip
  })

  tags = {
    Name = "app-server"
  }
}

# Instance: Database Server
resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = aws_key_pair.deployer.key_name

  # enable Public IP for downloading MySQL packages
  # Note: In a production environment this should be false.
  associate_public_ip_address = true

  # Inject credentials for MySQL setup
  user_data = templatefile("user_data_db.sh", {
    db_username = var.db_username
    db_password = var.db_password
  })

  tags = {
    Name = "db-server"
  }
}
