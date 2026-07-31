terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.81.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.14.0"

    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "rg" {
  name     = "ProjectLearningSteps"
  location = "westeurope"
  tags = {
    Environmet = "Learning steps cap"
    Owner      = "RPD"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = {
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "AKS-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "Postgresql_subnet" {
  name                 = "PostgreSQL-Subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "PostgreSQL-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}



# rbac time delay
resource "time_sleep" "wait_for_rbac" {
  depends_on      = [azurerm_role_assignment.rbac_akv]
  create_duration = "60s"
}

# create postgreSQL security group 
resource "azurerm_network_security_group" "postgres_nsg" {
  name                = "NSG_for_PostgreSQL"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# associate to postgres subnet
resource "azurerm_subnet_network_security_group_association" "postgres" {
  subnet_id                 = azurerm_subnet.Postgresql_subnet.id
  network_security_group_id = azurerm_network_security_group.postgres_nsg.id
}

# security group for AKS_subnet
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "NSG_for_AKS_Subnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet_network_security_group_association" "aks-postgres" {
  subnet_id                 = azurerm_subnet.aks_subnet.id
  network_security_group_id = azurerm_network_security_group.aks_nsg.id
}

#inbound rules aks-postgres
resource "azurerm_network_security_rule" "aks-lb-inbound" {
  name      = "Allow-AzureLoadBalancer"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "*"

  source_address_prefix      = "AzureLoadBalancer"
  destination_address_prefix = "*"
  source_port_range          = "*"
  destination_port_range     = "30000-32767"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_network_security_rule" "aks_node_communication" {
  name      = "Allow-AKS-Nodes"
  priority  = 110
  direction = "Inbound"
  access    = "Allow"
  protocol  = "*"

  source_address_prefix      = "10.0.0.0/24"
  destination_address_prefix = "10.0.0.0/24"

  source_port_range      = "*"
  destination_port_range = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# outbound rules aks-postgres
resource "azurerm_network_security_rule" "aks_to_postgres" {
  name      = "Allow-Postgres"
  priority  = 100
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "10.0.0.0/24"
  destination_address_prefix = "10.0.1.0/24"

  source_port_range      = "*"
  destination_port_range = "5432"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# Allow communication to services like Keyvault,ACR image pulls, Azure-apis, Monitoring, Kubernetes Services
resource "azurerm_network_security_rule" "aks_to_ACR" {
  name      = "Allow-AKS-Out"
  priority  = 110
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  destination_address_prefix = "AzureContainerRegistry"

  source_port_range      = "*"
  destination_port_range = "443"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_network_security_rule" "aks_to_monitor" {
  name      = "Allow-AKS-To-AzureMonitor"
  priority  = 130
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  destination_address_prefix = "AzureMonitor"

  source_port_range      = "*"
  destination_port_range = "443"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

resource "azurerm_network_security_rule" "aks_to_azurecloud" {
  name      = "Allow-Azure-Cloud"
  priority  = 140
  direction = "Outbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "*"
  destination_address_prefix = "AzureCloud"

  source_port_range      = "*"
  destination_port_range = "443"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}

# inbound rule only allow from aks dany everything else
resource "azurerm_network_security_rule" "postgres_from_aks" {
  name      = "Allow-AKS-To-Postgres"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "10.0.0.0/24"
  destination_address_prefix = "10.0.1.0/24"

  source_port_range      = "*"
  destination_port_range = "5432"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.postgres_nsg.name
}

resource "azurerm_network_security_rule" "aks_http_inbound" {
  name      = "Allow-HTTP-Internet"
  priority  = 120
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_address_prefix      = "Internet"
  destination_address_prefix = "*"

  source_port_range      = "*"
  destination_port_range = "80"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.aks_nsg.name
}
