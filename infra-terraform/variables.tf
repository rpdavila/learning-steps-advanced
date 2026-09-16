variable "environment" {
  type    = string
  default = "dev"
}

variable "owner" {
  type    = string
  default = "RPD"
}

variable "postgres_user" {
  type    = string
  default = "postgres"
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_db_name" {
  type    = string
  default = "learning_journal"
}

variable "tennant_id" {
  type = string
}

variable "keyvault_allowed_ip" {
  description = "Public IP allowed through the Key Vault firewall (the CI runner)"
  type        = string
}
