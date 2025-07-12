provider "aws" {
  region = "us-east-1"
}

# Create a security group with ALL inbound and outbound access
resource "aws_security_group" "open_all" {
  name        = "open_all_traffic"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # All IPs allowed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "my-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create EC2 instance
resource "aws_instance" "ec2" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.open_all.id]

  tags = {
    Name = "OpenAccessInstance"
  }

  # Optional: Add a user_data script (e.g., to install software)
}

# Output the public IP and private key
output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
