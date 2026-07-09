output "actions" {
  value       = local.final
  description = "Sorted, de-duplicated list of IAM actions produced from the inputs."
}

output "policy_json" {
  value = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = local.final
      Resource = "*"
    }]
  })
  description = "An IAM policy document (JSON) allowing the generated actions on all resources."
}
