resource "aws_vpc" "vpc_s" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "My Vpc"
  }
}

resource "aws_subnet" "publicsubnet1" {
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.128.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc_s.id
  tags = {
    Name = "Public_subnet1"
  }
}

resource "aws_subnet" "publicsubnet2" {
  availability_zone       = "us-east-1b"
  cidr_block              = "10.0.144.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc_s.id
  tags = {
    Name = "Public_subnet2"
  }
}

resource "aws_subnet" "privsubnet1" {
  availability_zone       = "us-east-1c"
  cidr_block              = "10.0.0.0/19"
  vpc_id                  = aws_vpc.vpc_s.id
  tags = {
    Name = "Private_subnet1"
  }
}

resource "aws_subnet" "privsubnet2" {
  availability_zone       = "us-east-1d"
  cidr_block              = "10.0.32.0/19"
  vpc_id                  = aws_vpc.vpc_s.id
  tags = {
    Name = "Private_subnet2"
  }
}

resource "aws_internet_gateway" "s_ig" {
  vpc_id = aws_vpc.vpc_s.id
  tags = {
    Name = "S-ig"
  }
}

 resource "aws_eip" "Nat-Gateway-EIP" {
   vpc = true
   tags = {
     Name = "NAT-EIP"
   }
 }

 resource "aws_nat_gateway" "s_ng" {
     depends_on = [aws_eip.Nat-Gateway-EIP]
     allocation_id = aws_eip.Nat-Gateway-EIP.id
     subnet_id = aws_subnet.publicsubnet1.id
     tags = {
       Name = "S-Nat"
     }
 }

 resource "aws_route_table" "s_rt2" {
   vpc_id = aws_vpc.vpc_s.id
   route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_nat_gateway.s_ng.id
   }

   tags = {
     Name = "Route table for Nat gateway"
   }
 }

resource "aws_route_table" "s_rt" {
  vpc_id = aws_vpc.vpc_s.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.s_ig.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

resource "aws_route_table_association" "s_rt_map" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.s_rt.id
}


 resource "aws_route_table_association" "s_rt2_map3" {
   subnet_id      = aws_subnet.privsubnet1.id
   route_table_id = aws_route_table.s_rt2.id
 }
