EC2 Instance Free tier eligible

Amazon 

Amazaon Linux 2023 kernel-6.1 AMI

```
resource "aws_instance" "Amazon Linux 2023 kernel-6.1"{
  ami = "ami-098e39bafa7e7303d"
  instance_type = "t3.micro"

  tags = {
    Name = "Amazaon Linux 2023 kernel-6.1 AMI"
  }
}
```

Amazon Linux 2023 kernel-6.18 AMI
```
resource "aws_instance" "Amazon Linux 2023 kernel-6.18" {
  ami = "ami-0c1e21d82fe9c9336"
  instance_type = "t3.micro"
  
  tags = {
    Name = "Amazon Linux 2023 kernel-6.18 AMI"
  }
}
```
Ubuntu

Ubuntu Server 26.04 LTS
```
resource "aws_instance" "Ubuntu Server 26.04 LTS" {
  ami = "ami-091138d0f0d41ff90"
  instance_type = "t3.micro"

  tags = {
    Name = "Ubuntu Server 26.04 LTS"
  }
}
```
Ubuntu Server 24.04
```
resource "aws_instance" "Ubuntu Server 24.04 LTS"{
  ami = "ami-05cf1e9f73fbad2e2"
  instance_type = "t3.micro"

  tags = {
    Name = "Ubuntu Server 24.04 LTS"
  }
}
```
Debian 

Debian 13
```
resource "aws_instance" "Debian 13"{
  ami = "ami-0b75f821522bcff85"
  instance_type = "t3.micro"

  tags = {
    Name = "Debian 13"
  }
}
```
