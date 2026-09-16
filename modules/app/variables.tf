variable "subscription_id" { 
  type = string 
}

variable "user_id" {
  type        = string
  description = "ID apprenant : nom + numero du Resource Group"
}

variable "environment" {
  type = string
}

variable "public_key_path" {
  type        = string
  description = "Chemin vers la clé publique SSH"
}
