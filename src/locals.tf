locals {

  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
  ami_id             = "ami-0c2b8ca1dad447f8a"
  instance_type      = "t2.micro"
  key_name           = "dev-srv-key"
}