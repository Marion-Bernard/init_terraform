locals {
  common_tags = {
    user        = var.user_id
    Project     = "azure-training"
    Environment = var.environment
    ManagedBy   = "terraform"
  } 
  common_config = {
    resource_group_name = "rg-MBernard2025_cours-multicloud"
    user_id             = var.user_id
    location = "francecentral"
 }
}
