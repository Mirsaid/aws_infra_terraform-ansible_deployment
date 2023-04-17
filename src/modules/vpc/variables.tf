variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"

}

variable "ami_id" {
  default = "ami-01a2825a801771f57" # Ubuntu 22.04 LTS AMI ID
}

variable "instance_type" {
  default = "t2.xlarge"
}
variable "key_name" {
  default = "dev-srv-key"
}
variable "private_key_path" {
  default = "modules/vpc/ansible/dev-srv-key.pem"
}

variable "ssh_user" {
  default = "ubuntu"
}
