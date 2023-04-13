# Resources

resource "aws_security_group" "ingress" {
  vpc_id      = aws_vpc.example_vpc.id
  name_prefix = "ingress"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "example_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "example_vpc"
  }
}

resource "aws_internet_gateway" "example_gateway" {
  vpc_id = aws_vpc.example_vpc.id

  tags = {
    Name = "example_gateway"
  }
}

resource "aws_subnet" "example_public_subnet" {
  vpc_id            = aws_vpc.example_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "example_public_subnet"
  }
}

resource "aws_route_table" "example_route_table" {
  vpc_id = aws_vpc.example_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_gateway.id
  }

  tags = {
    Name = "example_route_table"
  }
}

resource "aws_route_table_association" "example_association" {
  subnet_id      = aws_subnet.example_public_subnet.id
  route_table_id = aws_route_table.example_route_table.id
}

# resource "aws_network_interface" "example_network_interface" {
#   subnet_id       = aws_subnet.example_public_subnet.id
#   private_ips     = ["10.0.1.50"]
#   security_groups = [aws_security_group.ingress.id]

#   attachment {
#     device_index = 1
#     instance  = aws_instance.example_instance.id
#   }

#   #depends_on=[aws_subnet.example_public_subnet]

#   tags = {
#     Name = "example_network_interface"
#   }
 
  
# }

# resource "aws_eip" "one" {
#   vpc                       = true
#   network_interface         = aws_network_interface.example_network_interface.id
#   associate_with_private_ip = "10.0.1.50"
#   depends_on                = [aws_internet_gateway.example_gateway]
 
# }

resource "aws_instance" "example_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ingress.id]
  availability_zone      = "eu-central-1a"

  subnet_id                   = aws_subnet.example_public_subnet.id
   
  # network_interface {
  #   network_interface_id = aws_network_interface.example_network_interface.id
  #   device_index         = 1
  # }
  associate_public_ip_address = true   

  # Add a root EBS volume
  root_block_device {
    volume_size = 15
      }

  tags = {
    Name = "example_instance_for_project"
  }

#   user_data = <<-EOF
#  #!/bin/bash
#     apt-get update -y

#     # Mount EBS volume to instance and create file system
#     mkfs -t ext4 /dev/xvdf
#     mkdir /mnt/ebs_data
#     mount /dev/xvdf /mnt/ebs_data

#     # Install Java 8
#     apt-get install -y openjdk-8-jdk

#     # Run Python script
#     python /path/to/script.py

#   EOF
  
  # provisioner "remote-exec" {
  #   inline = [
    
  #   "sudo apt-get update -y",
  #     "sudo apt-get install -y openjdk-8-jdk",
  #     "export EBS_VOLUME=$(sudo lsblk -o NAME,MOUNTPOINT | tail -n1 | awk '{print $1}') ",
  #     "sudo mkfs -t ext4 $EBS_VOLUME",

  #     "sudo mkdir /mnt/ebs_data",
  #     "sudo mount $EBS_VOLUME /mnt/ebs_data",
  #     "cd /mnt/ebs_data",
  #     "python3 /modules/vpc/script.py "

  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("/modules/vpc/dev-srv-key.pem")
  #     host        = self.public_ip
  #   }
  # }


  provisioner "remote-exec" {
    inline = [
              "sudo apt update -y",
              "sudo apt-add-repository ppa:ansible/ansible -y",
              "sudo apt update -y",
              "sudo apt -y install ansible"
              ]

    connection {
      type        = "ssh"
      user        = "${var.ssh_user}"
      private_key = "${file("${var.private_key_path}")}"
      host        = "${self.public_ip}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' --private-key ${var.private_key_path} /ansible/ansible-playbook.yml"
  }

}

resource "aws_ebs_volume" "example_volume" {
  availability_zone = "eu-central-1a"
  size              = 50
  type              = "gp2"
  
  tags = {
    Name = "example_volume"
  }

}

resource "aws_volume_attachment" "example_volume_attachment" {
  device_name = "/dev/xvdb"   
  volume_id   = aws_ebs_volume.example_volume.id
  instance_id = aws_instance.example_instance.id

}

