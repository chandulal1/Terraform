# ==========================================
# 1. AWS - us-east-1 (t2.micro)
# ==========================================
resource "aws_key_pair" "chandu_key" {
  key_name   = "chandu-key"
  public_key = file("${path.module}/chandu.pub")
}

resource "aws_security_group" "aws_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all - restrict to your IP for better security
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "aws_vm" {
  ami                    = "ami-0c1fe732b5494dc14" # Amazon Linux 2023
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.chandu_key.key_name
  vpc_security_group_ids = [aws_security_group.aws_ssh.id]
  tags = { Name = "AWS-Free-VM" }
}

# ==========================================
# 2. AZURE - East US (B1s)
# ==========================================
# The Firewall (NSG)
# 1. The Resource Group (Missing according to error)
resource "azurerm_resource_group" "rg" {
  name     = "chandu-free-rg"
  location = "East US 2"
}

# 2. Virtual Network & Subnet (Required to create the NIC)
resource "azurerm_virtual_network" "vnet" {
  name                = "chandu-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 3. Public IP (So you can SSH)
resource "azurerm_public_ip" "pip" {
  name                = "chandu-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"   # Required for Standard SKU
  sku                 = "Standard"
}

# 4. The Network Interface (NIC) (Missing according to error)
resource "azurerm_network_interface" "nic" {
  name                = "chandu-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}
# 5. The Virtual Machine
resource "azurerm_linux_virtual_machine" "minimal_vm" {
  name                = "azure-free-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("${path.module}/chandu.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# (Note: Azure requires VNET, Subnet, and NIC - ensure these are in your file)
# The B1s instance uses the NIC associated with the NSG above.

# ==========================================
# 3. GCP - us-central1 (e2-micro)
# ==========================================
resource "google_compute_firewall" "gcp_ssh" {
  name    = "allow-ssh-gcp"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "gcp_vm" {
  name         = "gcp-free-vm"
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      type  = "pd-standard" # Standard disk is free tier
    }
  }
  network_interface {
    network = "default"
    access_config {} # Assigns external IP
  }
  metadata = {
    ssh-keys = "chandu:${file("${path.module}/chandu.pub")}"
  }
}

# ==========================================
# OUTPUTS - To get your Public IPs
# ==========================================
output "aws_ip" { value = aws_instance.aws_vm.public_ip }
output "azure_ip" { value = azurerm_linux_virtual_machine.minimal_vm.public_ip_address }
output "gcp_ip" { value = google_compute_instance.gcp_vm.network_interface[0].access_config[0].nat_ip }
