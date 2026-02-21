provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  vpc_name   = "phase3-vpc"
}

module "subnet" {
  source      = "./modules/subnet"
  vpc_id      = module.vpc.vpc_id
  cidr_block  = "10.0.1.0/24"
  az          = "us-east-1a"
  subnet_name = "phase3-subnet"
}

module "sg" {
  source  = "./modules/security-group"
  vpc_id  = module.vpc.vpc_id
  sg_name = "phase3-sg"
}

module "ec2" {
  source         = "./modules/ec2"
  ami_id         = "ami-xxxxxxxx"  # replace
  instance_type  = "t2.micro"
  subnet_id      = module.subnet.subnet_id
  sg_id          = module.sg.sg_id
  instance_name  = "phase3-ec2"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = "phase3-unique-bucket-name-123"
}
