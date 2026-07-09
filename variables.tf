variable "include_groups" {
  type        = list(string)
  default     = []
  description = <<-EOT
    Named permission groups whose read actions should be included. Valid groups:
    compute, containers, storage, networking, database, web, events, deployment,
    identity, governance, monitoring, security.
  EOT

  validation {
    condition = alltrue([
      for g in var.include_groups : contains([
        "compute", "containers", "storage", "networking", "database", "web",
        "events", "deployment", "identity", "governance", "monitoring", "security",
      ], g)
    ])
    error_message = "Unknown group. Valid groups: compute, containers, storage, networking, database, web, events, deployment, identity, governance, monitoring, security."
  }
}

variable "exclude_services" {
  type        = list(string)
  default     = []
  description = "Service prefixes (e.g. \"route53\") to drop from the final action list."
}

variable "exclude_actions" {
  type        = list(string)
  default     = []
  description = "Fully-qualified actions (e.g. \"s3:GetObject\") to drop from the final action list."
}

variable "include_actions" {
  type        = list(string)
  default     = []
  description = "Fully-qualified actions to add verbatim, in addition to any from include_groups."
}

variable "filter_actions" {
  type        = list(string)
  default     = []
  description = <<-EOT
    Candidate actions to include only after filtering. Wildcard actions (e.g.
    "s3:*", "s3:Get*") and write actions (Create/Delete/Update/Put/etc.) are
    dropped; the surviving read-only, non-wildcard actions are kept.
  EOT
}
