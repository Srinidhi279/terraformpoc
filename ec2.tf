resource "tls_private_key" "privkey" {
  algorithm = "RSA"
}

resource "aws_key_pair" "mykey"{
    key_name = "mykey"
    public_key = tls_private_key.privkey.public_key_openssh
}

resource "local_file" "private_key"{
    depends_on = [ tls_private_key.privkey ]
    content = tls_private_key.privkey.public_key_openssh
    filename = "mykey.pem"
}

resource "aws_security_group" "only_ssh_bastion"{
    name = "only-bastion"
    vpc_id = aws_vpc.vpc_s.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress{
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "only_ssh_bastion"
    }
}

resource "aws_instance" "Private_host"{
    ami = "ami-09d3b3274b6c5d4aa" 
    instance_type = "t2.micro"
    subnet_id = aws_subnet.privsubnet1.id
    vpc_security_group_ids = [aws_security_group.only_ssh_bastion.id]
    key_name = aws_key_pair.mykey.key_name
    iam_instance_profile = "${aws_iam_instance_profile.test_profile2.name}"

    tags = {
        Name = "Private-Host"
    }
}

resource "aws_instance" "Public_host"{
    ami = "ami-09d3b3274b6c5d4aa" 
    instance_type = "t2.micro"
    subnet_id = aws_subnet.publicsubnet1.id
    vpc_security_group_ids = [aws_security_group.only_ssh_bastion.id]
    key_name = aws_key_pair.mykey.key_name
    iam_instance_profile = "${aws_iam_instance_profile.test_profile2.name}"

    tags = {
        Name = "Public-Host"
    }
}


# resource “aws_instance” “web” {
# ami = “ami-02e136e904f3da870”
# instance_type = “t2.micro”
# vpc_security_group_ids = [aws_security_group.web-sg.id]
# iam_instance_profile = aws_iam_instance_profile.SSMRoleForEC2.name
# user_data = <<EOF
# #!/bin/bash
# sudo su
# yum update -y
# yum install httpd -y
# aws s3 cp s3://${aws_s3_bucket.blog.id}/index.html /var/www/html/index.html
# systemctl start httpd
# systemctl enable httpd
# EOF
# tags = {
# Name = “Whiz-EC2-Instance”
# }
# }