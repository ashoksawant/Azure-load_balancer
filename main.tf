data "azurerm_resource_group" "example" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.vnet_name}_${var.env}"
  location            = data.azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_subnet" "subnet1" {
  name                = "${var.subnet_name}_${var.env}"
  resource_group_name = data.azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes    = ["10.0.2.0/24"]
}

resource "azurerm_network_security_group" "NSG1" {
  name                = "${var.nsg_name}_${var.env}"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHealthProbe"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
  }
}

resource "azurerm_public_ip" "pub1" {
  name                = "${var.pub_name}_${var.env}"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  allocation_method   = "Static"
  domain_name_label   = "${var.pub_name}-${var.env}"

  tags = {
    environment = var.env
  }
}

resource "azurerm_lb" "web_lb" {
  name                = "${var.loadbalancer_name}_${var.env}"
  resource_group_name = data.azurerm_resource_group.example.name
  location            = data.azurerm_resource_group.example.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "web-lb-publicip-1"
    public_ip_address_id = azurerm_public_ip.pub1.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_lb_backend_address_pool" {
  name             = "web-backend"
  loadbalancer_id  = azurerm_lb.web_lb.id
}

resource "azurerm_lb_probe" "web_lb_probe" {
  name             = "tcp-probe"
  protocol         = "Tcp"
  port             = 80
  loadbalancer_id  = azurerm_lb.web_lb.id
}

resource "azurerm_lb_rule" "web_lb_rule_app1" {
  name                             = "web-app1-rule"
  protocol                         = "Tcp"
  frontend_port                    = 80
  backend_port                     = 80
  frontend_ip_configuration_name   = azurerm_lb.web_lb.frontend_ip_configuration[0].name
  backend_address_pool_ids         = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
  probe_id                         = azurerm_lb_probe.web_lb_probe.id
  loadbalancer_id                  = azurerm_lb.web_lb.id
}

locals {
  appvm_custom_data = <<CUSTOM_DATA
#!/bin/sh
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd  
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo chmod -R 777 /var/www/html 
sudo mkdir /var/www/html/appvm
sudo echo "Welcome to stacksimplify - AppVM App1 - VM Hostname: $(hostname)" > /var/www/html/index.html
sudo echo "Welcome to stacksimplify - AppVM App1 - VM Hostname: $(hostname)" > /var/www/html/appvm/hostname.html
sudo echo "Welcome to stacksimplify - AppVM App1 - App Status Page" > /var/www/html/appvm/status.html
sudo echo '<!DOCTYPE html> <html> <body style="background-color:rgb(255, 99, 71);"> <h1>Welcome to Stack Simplify - AppVM APP-1 </h1> <p>Terraform Demo</p> <p>Application Version: V1</p> </body></html>' | sudo tee /var/www/html/appvm/index.html
CUSTOM_DATA
}

resource "azurerm_linux_virtual_machine_scale_set" "app_vmss" {
  name                            = "${var.vmscale_set_name}-${var.env}"
  resource_group_name             = data.azurerm_resource_group.example.name
  location                        = data.azurerm_resource_group.example.location
  sku                             = "Standard_DS1_v2"
  instances                       = 2
  admin_username                  = "azureuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "83-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  upgrade_mode = "Automatic"

  network_interface {
    name                      = "app-vmss-nic"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.NSG1.id

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = azurerm_subnet.subnet1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web_lb_backend_address_pool.id]
    }
  }

  custom_data = base64encode(local.appvm_custom_data)

  depends_on = [
    azurerm_lb.web_lb,
    azurerm_lb_backend_address_pool.web_lb_backend_address_pool,
    azurerm_lb_probe.web_lb_probe
  ]
}