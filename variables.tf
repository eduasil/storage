
variable "resource_group_name" {
  default = "RG_TEST_NSP"
}

variable "location" {
  description = "Localização do recurso"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  default = "stnsptest1"
}

variable "account_tier" {
  description = "Tier da conta de armazenamento"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Tipo de replicação da conta"
  type        = string
  default     = "LRS"
}