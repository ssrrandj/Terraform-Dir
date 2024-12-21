provider "aws" {
  region = "us-east-1"
}


resource "aws_vpc" "appvpc" {
    cidr_block = "192.168.0.0/16"
tags = {
  Name="appvpc"
  description="vpc for app"
}
}

/* resource "aws_instance" "example" { Multiple instance with different nsmes using
  for_each      = {
    "Tomcat" = "ami-0657605d763ac72a8",
    "Backend" = "ami-0657605d763ac72a8",
    "Mysql" = "ami-0657605d763ac72a8"
  }

  ami           = each.value
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.TestPUBSub.id
  key_name      = "Test"

  tags = {
    Name = each.key  # Dynamically assigning names based on the key of the map
  }
}
*/
resource "aws_route_table" "apprt" {
    depends_on = [ aws_vpc.appvpc ]
  vpc_id = aws_vpc.appvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.appIGW.id
  }
tags = {
    Name="apprt"
    description="Route table for app"
}
}

resource "aws_route_table_association" "RTAS" {
    subnet_id = aws_subnet.appsub.id
    route_table_id = aws_route_table.apprt.id
  
}


resource "aws_subnet" "appsub" {
    vpc_id = aws_vpc.appvpc.id
    cidr_block = "192.168.0.0/24"
    map_public_ip_on_launch = true

tags = {
  Name="appsub"
  description="subnet for app"
}
}


resource "aws_internet_gateway" "appIGW" {
tags = {
    Name="appIGW"
    description="IGW for app"
}
}

resource "aws_internet_gateway_attachment" "appIGWATC" {
    depends_on = [ aws_vpc.appvpc ]
  internet_gateway_id = aws_internet_gateway.appIGW.id
  vpc_id = aws_vpc.appvpc.id
}

resource "null_resource" "IGWATC" {
    provisioner "local-exec" {
      command = "echo 'Gateway ${aws_internet_gateway.appIGW.id} attached to VPC ${aws_vpc.appvpc.id}'"
    }
  
}

resource "aws_security_group" "apSG" {
  vpc_id = aws_vpc.appvpc.id
  ingress {
    description = "Allow to access apache"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
  Name="apSG"
  description="SG for apSG to allow apache at 8081"
}
}

resource "aws_instance" "App" {
    
    depends_on = [ aws_subnet.appsub ]
    
    instance_type = "t2.micro"
    ami = "ami-0e2c8caa4b6378d8c"
    subnet_id = aws_subnet.appsub.id
    key_name = "NVirginia"
    security_groups = [aws_security_group.apSG.id]
    
tags = {
    Name="AppInstance"
    description="App instance"
}
associate_public_ip_address = true
}

output "instance_ip" {
  value = aws_instance.App.public_ip
}




resource "null_resource" "script" {
    depends_on = [ aws_instance.App ]
    provisioner "remote-exec" {
      inline = [ 
        "sleep 60",
        "sudo apt update -y",
        "sudo apt install git -y",
        "sudo apt install apache2 -y",
        "sudo systemctl enable apache2",
        "git clone https://github.com/ssrrandj/First-Project.git",
        "sudo rm /var/www/html/index.html",
        "cd First-Project/",
        "sudo cp *.html /var/www/html/"
       ]
    }
    provisioner "local-exec" {
      command = "echo Instance IP ${aws_instance.App.public_ip}"
    } 
connection {
    user = "ubuntu"
    private_key = file("C:/Users/91939/Downloads/NVirginia.pem")
    host = aws_instance.App.public_ip
  }
}
