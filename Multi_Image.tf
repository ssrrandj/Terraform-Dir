provider "aws" {
  region = var.global[0]["region"] # Accessing the first element of the global list
}

output "global_debug" {
  value = var.global
}

resource "aws_vpc" "App" {
  # Transform configurations into a map for for_each
  for_each = { for i, conf in var.configurations : i => conf } # Converting list of elements which are in map format to map 

  cidr_block = each.value["vpc_cird"] # Accessing vpc_cird from the configuration map

  tags = {
    Name        = "InstanceVPC - ${each.value["instance_name"]}" # Access instance_name
    Description = "VPC for ${each.value["instance_name"]}"       # Corrected description
  }
}

resource "aws_subnet" "AppSubnet" {
  # Reusing the same for_each logic as above
  for_each = { for i, conf in var.configurations : i => conf }

  vpc_id     = aws_vpc.App[each.key].id  # Ties subnet to the correct VPC
  cidr_block = each.value["subnet_cird"] # Accessing subnet_cird

  tags = {
    Name        = "InstanceSub - ${each.value["instance_name"]}" # Access instance_name
    Description = "Subnet for ${each.value["instance_name"]}"    # Corrected description
  }
}

resource "aws_internet_gateway" "AppIGW" {
    for_each = {for i, conf in var.configurations : i => conf}
  vpc_id = aws_vpc.App[each.key].id # Ties IGW to correct VPC
tags = {
    Name        = "InstanceIGW - ${each.value["IGW"]}" # Access instance_name
    Description = "Subnet for ${each.value["IGW"]}"    # Corrected description
}
}

resource "aws_route_table" "AppRT" {
    for_each = {for i, conf in var.configurations : i => conf}
    vpc_id = aws_vpc.App[each.key].id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.AppIGW[each.key].id
    }
tags = {
     Name        = "InstanceRT - ${each.value["R_table"]}" # Access instance_name
    Description = "Subnet for ${each.value["R_table"]}"    # Corrected description
}
}

resource "aws_route_table_association" "AppRTASS" {
    for_each = {for i, conf in var.configurations : i => conf}
    route_table_id = aws_route_table.AppRT[each.key].id
    subnet_id = aws_subnet.AppSubnet[each.key].id  
}

resource "aws_security_group" "AppSG" {
    for_each = {for i, conf in var.configurations : i => conf}
    vpc_id = aws_vpc.App[each.key].id
   
tags = {
     Name        = "InstanceRT - ${each.value["security_groups_name"]}"  # Access instance_name
    Description = "Subnet for ${each.value["security_groups_name"]}"    # Corrected description
}
}

resource "aws_instance" "AppInstance" {
  for_each = {for i, conf in var.configurations : i => conf}
  ami = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.AppSG[each.key].id]
  subnet_id = aws_subnet.AppSubnet[each.key].id
  key_name = "NVirginia"

tags = {
  Name = "Instance - ${each.value["instance_name"]}"
  description = "Instance is for - ${each.value["instance_name"]}}"
}
}






