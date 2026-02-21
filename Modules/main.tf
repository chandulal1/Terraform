provider "aws" {
  region = var.region
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
  vpc_name   = "phase3-vpc"
}

module "subnet" {
  source      = "./modules/subnet"
  vpc_id      = module.vpc.vpc_id
  cidr_block  = var.subnet_cidr
  az          = var.availability_zone
  subnet_name = "phase3-subnet"
}

module "sg" {
  source  = "./modules/security-group"
  vpc_id  = module.vpc.vpc_id
  sg_name = "phase3-sg"
}

module "ec2" {
  source         = "./modules/ec2"
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  subnet_id      = module.subnet.subnet_id
  sg_id          = module.sg.sg_id
  instance_name  = "phase3-ec2"
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}
