provider "aws" {
   region="eu-central-1"
}

resource "aws_instance" "my_webserver" {
    ami = "ami-0d51a78a0a50b60e1" 
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.sec_gr_myserver.id]
    user_data = <<EOF
#!/bin/bash
sudo su
yum -y install httpd
myiplocal=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
myippublic=`curl http://169.254.169.254/latest/meta-data/public-ipv4` 
echo "<h1> My Instance, by terraform! </h1><br> <p>IP(local): $myiplocal </p><br><p>IP(public): $myippublic</p>" >> /var/www/html/index.html
sudo systemctl enable httpd --now
#sudo systemctl start httpd
EOF

tags = {
    Name="web server"
    Owner="Merlen"
}
}

output "DNS" {
  value = aws_instance.my_webserver.public_dns
}

resource "aws_security_group" "sec_gr_myserver" {
  name        = "Web Server Security Group"
  description = "This my first create security group for my web server"

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
