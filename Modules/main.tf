provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source         = "./modules/ec2"
  ami_id         = "ami-xxxxxxxx"   # replace with valid AMI
  instance_type  = "t2.micro"
  instance_name  = "phase3-module"
}
