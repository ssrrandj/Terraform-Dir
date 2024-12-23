variable "App_SGRL" {
  type = map(map(any))
  default = {
  
  "AppSGR" = {
      "ingress" = [
        { from_port = 8081, to_port = 8081, protocol = "tcp", cidr_block = "0.0.0.0/0" },
        { from_port = 22, to_port = 22, protocol = "ssh", cidr_block = "0.0.0.0/0" }
      ]
    },
    "BDSG" = {
      "ingress" = [
        { from_port = 3306, to_port = 3306, protocol = "tcp", cidr_block = "0.0.0.0/0" },
        {from_port = 3306, to_port = 3306, protocol = "tcp", cidr_block = "0.0.0.0/0"}
      ]
    },
    "BackendSG" = {
      "ingress" = [
        { from_port = 0, to_port = 65535, protocol = "tcp", cidr_block = "0.0.0.0/0" },
        { from_port = 22, to_port = 22, protocol = "ssh", cidr_block = "0.0.0.0/0" }
      ]
    }
  
  }
  }