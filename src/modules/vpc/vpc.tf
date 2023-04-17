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

resource "aws_instance" "example_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ingress.id]
  availability_zone      = "eu-central-1a"

  subnet_id = aws_subnet.example_public_subnet.id

  associate_public_ip_address = true

  # Add a root EBS volume
  root_block_device {
    volume_size = 15
  }

  tags = {
    Name = "example_instance_for_project"
  }

  #############################################################################
  # This is the 'remote exec' method.  
  # Ansible runs on the target host.
  #############################################################################

  provisioner "remote-exec" {
    inline = [
      "mkdir /home/${var.ssh_user}/files",
      "mkdir /home/${var.ssh_user}/ansible",
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      host        = self.public_ip
      private_key = file("${var.private_key_path}")
    }
  }
  provisioner "file" {
    source      = "modules/vpc/ansible/ansible-playbook.yml"
    destination = "/home/${var.ssh_user}/ansible/ansible-playbook.yml"

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file("${var.private_key_path}")
    }
  }

  provisioner "remote-exec" {
    inline = [
	"sudo apt update -y",
              "sudo apt-add-repository ppa:ansible/ansible -y",
              "sudo apt update -y",
              "sudo apt -y install ansible",
      "cd ansible; ansible-playbook -c local -i \"localhost,\" ansible-playbook.yml",
    ]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file("${var.private_key_path}")
    }
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


