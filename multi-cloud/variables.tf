# --- AWS VARIABLES ---
variable "aws_access_key" {
  type      = string
  sensitive = true
}
variable "aws_secret_key" { 
    type = string
 sensitive = true 
}

# --- AZURE VARIABLES ---
variable "azure_subscription_id" { type = string }
variable "azure_client_id"       { type = string }
variable "azure_client_secret" { 
    type = string
 sensitive = true 
}
variable "azure_tenant_id"       { type = string }

# --- GCP VARIABLES ---
variable "gcp_project_id" { type = string }
variable "gcp_auth_file"  { type = string } # Path to your .json key