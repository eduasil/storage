
output "next_steps" {
  value = <<EOT

🎉 Storage Account criado com sucesso!

EOT
}

output "storage_account_id" {
  description = "ID da Storage Account"
  value       = azurerm_storage_account.storage.id
}

output "storage_account_primary_endpoint" {
  description = "Endpoint primário da Storage Account"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}
