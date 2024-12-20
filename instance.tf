provider "aws" {
  region = "us-west-1"
  default_tags {
    tags = {
    Owner="Raja"
    Project="Test"
  }
  }
}

resource "aws_vpc" "TestVpc" {
  cidr_block = "198.168.0.0/24"
tags = {
  Name="TestVPC"
  
}
}

resource "null_resource" "outut" {
  depends_on = [ aws_vpc.TestVpc ]
  provisioner "local-exec" {
    command = "echo 'VPC Created'"
  }
}

resource "aws_internet_gateway" "TestIGW" {
tags = {
  Name="TestIGW"
}
}

resource "null_resource" "TestIGW" {
  provisioner "local-exec" {
    command = " echo 'Internet_Gateway created for VPC ${aws_vpc.TestVpc.id} '"  
  }
}

resource "aws_internet_gateway_attachment" "TestIGWA" {
  vpc_id = aws_vpc.TestVpc.id
  internet_gateway_id = aws_internet_gateway.TestIGW.id
}

resource "null_resource" "TestIGWA" {
  provisioner "local-exec" {
    command = " echo 'Attached IGW to VPC ${aws_vpc.TestVpc.id}'"
  } 
}

resource "aws_subnet" "TestPVTSub" {
  vpc_id = aws_vpc.TestVpc.id
  cidr_block = "198.168.0.0/25"
tags = {
  Name="TestPVTSub"
}
}

resource "aws_subnet" "TestPUBSub" {
  vpc_id = aws_vpc.TestVpc.id
  cidr_block = "198.168.0.128/25"
  map_public_ip_on_launch = true
tags = {
  Name="TestPUBSub"
}
}

resource "aws_route_table" "TestPVTRT" {
  vpc_id = aws_vpc.TestVpc.id
tags = {
  Name="TestPVTRT"
}
}

resource "aws_route_table" "TestPUBRT" {
  vpc_id = aws_vpc.TestVpc.id
tags = {
  Name="TestPUBRT"
}
}

resource "aws_route_table_association" "TestPUBRT" {
  subnet_id = aws_subnet.TestPUBSub.id
  route_table_id = aws_route_table.TestPUBRT.id
}

resource "aws_route" "TestPUBRTRT" {
  depends_on = [ aws_internet_gateway.TestIGW ]
   destination_cidr_block = "0.0.0.0/0"
  route_table_id = aws_route_table.TestPUBRT.id
  gateway_id = aws_internet_gateway.TestIGW.id
}

resource "aws_security_group" "TestSG" {
  vpc_id = aws_vpc.TestVpc.id
  
  ingress {
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name="TestSG"
  }
}

resource "aws_instance" "Test_instance" {
  ami = "ami-0657605d763ac72a8"
  instance_type = "t2.micro"
  key_name = "Test"
  subnet_id = aws_subnet.TestPUBSub.id
  user_data = file("k8.sh")
tags = {
  Name="Test_instance"
}
associate_public_ip_address = true
}



output "aws-public_ip" {
  value = aws_instance.Test_instance.public_ip
}

resource "null_resource" "GitFile" {
  depends_on=[aws_instance.Test_instance]
  provisioner "remote-exec" {
    inline = [  
      "sleep 60",
     "sudo apt update -y",
     "sudo apt install git -y",
     "git clone https://github.com/ssrrandj/vprofile-project.git"
    ]
  }
  provisioner "local-exec" {
    command = "echo public IP ${aws_instance.Test_instance.public_ip}"
  }

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("C:/Users/91939/OneDrive/Desktop/Test.pem")
    host = aws_instance.Test_instance.public_ip
    }
}

