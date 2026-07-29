variable "environment" {
  type = string
}

variable "appid" {
  type = string
}

variable "password" {
  type = string
}

variable "owner" {
  type = string
}

variable "postgres_user" {
  type    = string
  default = "postgres"
}

variable "postgres_password" {
  type    = string
  default = "postgres"
}

variable "postgres_db_name" {
  type    = string
  default = "learning_journal"
}

variable "tennant_id" {
  type = string
}

variable "service_principal_id" {
  type = string
}