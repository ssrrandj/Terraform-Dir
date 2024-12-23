variable "global" {
    default = [
        {
            region = "us-east-1"
            instance_type = "t2.micro"
            description = "Java App"
            Owner = "Java"
            }
    ] 
}

variable "configurations" {
    default = [
        {
            vpc_cird = "192.168.0.0/24"
            instance_name = "App"
            subnet_cird = "192.168.0.0/28"
            Instance_description = "Instance for App"
            Instance_IGW = "AppIGW"
            Instance_vpctable = "Appvpc"
            Instance_subnettable = "AppSubnet"
            Instance_RouteTableName = "AppRT"
            R_table = "AppRT"
            IGW = "AppIGW"
            security_groups_name = "AppSG"
            
        
        },

        {
            vpc_cird = "192.168.1.0/24"
            security_groups_name = "BDSG"
            instance_name = "DB"
            subnet_cird = "192.168.1.0/28"
            Instance_description = "Instance for DB"
            IGW = "DBIGW"
            R_table = "DBRT"
            
         },
         
         {
            vpc_cird = "192.168.2.0/24"
            instance_name = "Backend"
            security_groups_name = "BackendSG"
            subnet_cird = "192.168.2.0/28"
            Instance_description = "Instance for Backend"
            IGW = "BackendIGW"
            R_table = "BackendRT"
         }     
     ] 
     }
  
