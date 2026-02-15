terraform {
  required_providers {
    aws     = { source = "hashicorp/aws"
      version = "~> 6.0" 
    }
    azurerm = { source = "hashicorp/azurerm"
     version = "~> 4.0" 
    }
    google  = { source = "hashicorp/google"
    version = "~> 7.0" 
    }
  }
}

# 1. AWS
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# 2. Azure
provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

# 3. Google Cloud
provider "google" {
  project     = var.gcp_project_id
  credentials = file("${path.module}/${var.gcp_auth_file}")
  region      = "us-central1"
  zone        = "us-central1-a"
}