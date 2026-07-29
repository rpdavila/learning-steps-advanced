terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "learningstepstfstate29"
    container_name       = "tfstate"
    key                  = "learningsteps.tfstate"
  }
}