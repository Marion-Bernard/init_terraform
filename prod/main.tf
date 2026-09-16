provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

module "app" {
  source          = "../modules/app"
  environment     = "prod"
  subscription_id = var.subscription_id
  public_key_path = var.public_key_path
  user_id         = var.user_id 
}

variable "subscription_id" { type = string }
variable "public_key_path" { type = string }
variable "user_id"         { type = string }
