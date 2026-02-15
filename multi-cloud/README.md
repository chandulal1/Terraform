1. providers.tf — The Handshake
This is the first file Terraform reads. It tells Terraform which plugins to download (AWS, Azure, or GCP) and how to authenticate with them.

What it does: It defines the "translation layers." Terraform speaks HCL (HashiCorp Configuration Language), but AWS speaks its own API. The provider translates your code into those API calls.

Key Content: It contains provider "aws", provider "azurerm", and provider "google" blocks that use the variables from your variables.tf.

2. variables.tf — The Definitions
Think of this as the dictionary for your project. It doesn't set the values; it just declares that certain labels exist.

What it does: It tells Terraform, "Expect a piece of data called azure_client_secret, and it should be a string."

Why use it: It allows you to reuse the same code for different environments. Instead of hardcoding your Secret Key everywhere, you use the variable name. If the key changes, you only change it in one place.

3. terraform.tfvars — The Secret Vault
This is where the actual sensitive values live.

What it does: It assigns real values to the names you created in variables.tf. (e.g., azure_client_id = "38003e8e...").

Security Tip: This file should never be uploaded to GitHub. It contains the "keys to your kingdom." Usually, we add *.tfvars to a .gitignore file.

4. main.tf — The Blueprint
This is the heart of your project. It describes exactly what you want to build.

What it does: It defines the Resources. You told Terraform you wanted a Resource Group, a Virtual Network, and a Linux VM.

The Logic: It uses "Dependency Mapping." For example, your NIC (Network Interface) refers to azurerm_subnet.subnet.id. Terraform is smart enough to know it must build the Subnet before it builds the NIC.

5. terraform.tfstate — The Memory
This is a JSON file created after you run terraform apply.

What it does: It maps your code to real-world IDs.

In main.tf, you call it minimal_vm.

In the real world, Azure gave it a long ID like /subscriptions/.../virtualMachines/azure-free-vm.

Why it's critical: If you run terraform apply a second time, Terraform looks at this file, compares it to your code, and says, "Oh, I already built that VM, I don't need to do it again." If you delete this file, Terraform will lose its memory and try to build everything again from scratch (causing "Already Exists" errors).

🔄 The Workflow Summary
providers.tf downloads the tools.

variables.tf sets the rules for data.

terraform.tfvars provides the login credentials.

main.tf draws the map of the servers.

terraform.tfstate remembers what was actually built.
