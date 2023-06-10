module "include_groups" {
  source = "../"

  # Include specific groups who actions you want included
  include_groups = ["deployment", "networking"]
}
output "include_groups" {
  value = module.include_groups.actions
}


module "filter_actions" {
  source = "../"

  # Add actions but filter out writes
  filter_actions = [
    "s3:Get*",
    "s3:*",
    "networkmanager:UpdateVpcAttachment",
    "vpc-lattice:DeleteRule",
    "vpc-lattice:PutResourcePolicy",
    "apprunner:ListVpcConnectors",
    "apprunner:ListVpcIngressConnections",
    "apprunner:UpdateVpcIngressConnection",
    "devicefarm:CreateVPCEConfiguration",
    "devicefarm:DeleteVPCEConfiguration",
  ]
}
output "filter_actions" {
  value = module.filter_actions.actions
}

module "exclude_services" {
  source = "../"

  include_groups = ["deployment", "networking"]
  # Add groups but filter out services
  exclude_services = [
    "route53",
  ]
}
output "exclude_services" {
  value = module.exclude_services.actions
}
