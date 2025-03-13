# Azure Load Balancer Project

## Overview
This repository contains the infrastructure code for deploying Azure Load Balancers using Terraform. The project is structured to support multiple environments, including development (dev) and production (prod), with separate branches and environment variables for each.

## Branches
- **dev**: Contains the infrastructure code for the development environment.
- **prod**: Contains the infrastructure code for the production environment.

## Features
- Automated deployment of Azure Load Balancers.
- Environment-specific configurations.
- Infrastructure as Code (IaC) using Terraform.
- Continuous Integration and Continuous Deployment (CI/CD) using Azure DevOps.

## Getting Started

### Prerequisites
- Terraform installed on your local machine.
- Azure subscription.
- Azure CLI installed and authenticated.

### Clone the Repository
```bash
git clone <repository-url>
Checkout the Desired Branch
git checkout dev  # For development
git checkout prod  # For production
Configure Environment Variables
Set the necessary environment variables in your Azure DevOps pipelines or locally.

Deploy the Infrastructure
Run the following commands to deploy the infrastructure:

terraform init
terraform plan
terraform apply
Repository Structure
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
├── provider.tf 
├── backend.tf
├── terraform.tfvars 

** Resources
Resource Group: Defines the Azure resource group.
Virtual Network: Defines the virtual network and subnet.
Network Security Group: Defines the security rules for the network.
Public IP: Defines the public IP address for the load balancer.
Load Balancer: Defines the load balancer and its configurations.
Backend Address Pool: Defines the backend address pool for the load balancer.
Health Probe: Defines the health probe for the load balancer.
Load Balancer Rule: Defines the load balancing rule.
Virtual Machine Scale Set: Defines the virtual machine scale set.
Custom Data
The virtual machine scale set uses custom data to configure the VMs. The custom data script installs and configures Apache HTTP server.

Contributing
Feel free to contribute by opening issues or submitting pull requests. Ensure that your changes are tested in the dev branch before merging into prod.