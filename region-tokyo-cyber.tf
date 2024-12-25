# Tokyo Security VPC

resource "aws_vpc" "VPC-Cyber-Tokyo" {
    
    provider = aws.tokyo
    cidr_block = "10.19.0.0/16"

  tags = {
    Name = "VPC-Cyber-Tokyo"
    Service = "cybersecurity"
    Owner = "Frodo"
    Planet = "Arda"
  }
}


#------------------------------------------------------------#
#  Tokyo VPC Public IP space.
# Remove public IP space for Cyber VPC as of 25 December 2024.
/*
resource "aws_subnet" "public-cyber-ap-northeast-1d" {
    vpc_id                  = aws_vpc.VPC-Cyber-Tokyo.id
    cidr_block              = "10.19.1.0/24"
    availability_zone       = "ap-northeast-1d"
    map_public_ip_on_launch = true
    provider = aws.tokyo

    tags = {
    Name    = "public-cyber-ap-northeast-1d"
    Service = "cybersecurity"
    Owner   = "Frodo"
    Planet  = "Arda"
    }
}
*/

# Tokyo Private IP space.

resource "aws_subnet" "private-cyber-ap-northeast-1d" {
  vpc_id                  = aws_vpc.VPC-Cyber-Tokyo.id
  cidr_block              = "10.19.11.0/24"
  availability_zone       = "ap-northeast-1d"
  provider = aws.tokyo
  
  tags = {
    Name    = "private-cyber-ap-northeast-1d"
    Service = "cybersecurity"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}



#--------------------------------------------------------#
# Internet Gateway (IGW)

resource "aws_internet_gateway" "igw_CYBER_TYO" {
  vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
  provider = aws.tokyo


  tags = {
    Name    = "CYBER_TYO_IGW"
    Service = "cybersecurity"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

#--------------------------------------------------------#
# Tokyo NAT
/*
resource "aws_eip" "eip_CYBER_TYO" {
  vpc = true
  provider = aws.tokyo

  tags = {
    Name = "eip_CYBER_TYO"
  }
}

resource "aws_nat_gateway" "nat_CYBER_TYO" {
  allocation_id = aws_eip.eip_CYBER_TYO.id
  subnet_id     = aws_subnet.public-cyber-d.id
  provider = aws.tokyo

  tags = {
    Name = "nat_CYBER_TYO"
  }

  depends_on = [aws_internet_gateway.igw_CYBER_TYO]
}
*/


#----------------------------------------------------#
# Subnets
#
# Public Network

resource "aws_route_table" "public_CYBER_Tokyo" {
  vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
  provider = aws.tokyo

  route   {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw_CYBER_TYO.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  
    tags = {
    Name = "public_cyber_tokyo"
  }
}

#-----------------------------------------------#
#
# These are for the public subnets.

resource "aws_route_table_association" "public-cyber-d" {
  subnet_id      = aws_subnet.public-cyber-ap-northeast-1d.id
  route_table_id = aws_route_table.public_CYBER_Tokyo.id
  provider = aws.tokyo
}

resource "aws_route_table_association" "public-cyber-ap-northeast-1d" {
  subnet_id      = aws_subnet.public-cyber-ap-northeast-1d.id
  route_table_id = aws_route_table.public_CYBER_Tokyo.id
  provider = aws.tokyo
}

#-----------------------------------------------#
# Private Network


resource "aws_route_table" "private_CYBER_Tokyo" {
  vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
  provider = aws.tokyo
  
  
  route  {
      cidr_block                 = "10.0.0.0/8"
      nat_gateway_id             = "" # aws_nat_gateway.nat_CYBER_TYO.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = aws_ec2_transit_gateway.Tokyo-Region-TGW.id
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

  tags = {
    Name = "private_CYBER_Tokyo"
  }
}


# These are for the private subnets.
resource "aws_route_table_association" "private-cyber-ap-northeast-1d" {
  subnet_id      = aws_subnet.private-cyber-ap-northeast-1d.id
  route_table_id = aws_route_table.private_CYBER_Tokyo.id
  provider = aws.tokyo
}


#---------------------------------------------------------------------#
# Security Groups
#

# Bastion Server Security Group
# Not created at this phase.

# Security Group for Tokyo Syslog Server"
#

resource "aws_security_group" "SG01-CYBER-TYO-SYSLOG" {
    name = "SG04-TYO-SYSLOG"
    description = "Allow SSH and SYSLOG traffic to security servers."
    vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
    provider = aws.tokyo

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "SYSLOG"
        from_port = 514
        to_port = 514
        protocol = "UDP"
        cidr_blocks = ["10.0.0.0/8"]
    }


    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "SG01-CYBER-TYO-SYSLOG"
        Service = "syslog"
        Owner = "Frodo"
        Planet = "Arda"
    }
}




