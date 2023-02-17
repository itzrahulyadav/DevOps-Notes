provider "aws" {
    region = "ap-south-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name:"${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name:"${var.env_prefix}-subnet-1"
    }
}

# creating the route table

# resource "aws_route_table" "myapp-route-table" {
#     vpc_id = aws_vpc.myapp-vpc.id
#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id
#     }
#     tags = {
#         Name:"${var.env_prefix}-rt"
#     }
# }

# create the internet gateway

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name:"${var.env_prefix}-igw"
    }

}

/*
resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-route-table.id
}
*/


# configuring the defualt route table to allow internet traffic by specifying routes.

resource "aws_default_route_table" "main_rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }

    tags = {
        Name = "${var.env_prefix}-main-rt"
    }
}

# Creating the security group allowing ssh and port 8080

resource "aws_security_group" "myapp-sg" {
    name = "myapp-sg"
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22 #lowerbound
        to_port = 22   #upperbound
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80 #lowerbound
        to_port = 80   #upperbound
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0 #lowerbound
        to_port = 0   #upperbound
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "${var.env_prefix}-sg"
    }
}


# fetching ami for ec2-instance

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

# resource "aws_key_pair" "ssh-key" {
#     key_name = "server-key"
#     public_key = "file(var.public_key_location)" #your public ssh key located in .ssh foler
# }

resource "aws_instance" "myapp-server" {
    ami = "ami-0e742cca61fb65051"
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_security_group.myapp-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = "rxhxl-key-pair"

    tags = {
        Name = "${var.env_prefix}-server"
    }

    #running the entrypoint script
    
    user_data = <<EOF
            #!/bin/bash
            sudo yum update -y
            sudo yum install -y httpd
            sudo systemctl start httpd
            sudo systemctl enable httpd
            echo "<html><body><h1>Rahul Yadav's server</h1></body></html>" >> /var/www/html/index.html
        EOF


}

