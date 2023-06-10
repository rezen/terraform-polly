# terraform-polly
Generate policies for the services in terraform you want to use.

## Examples
**Include specific groups who actions you want included**  
```hcl
module "include_groups" {
  source = "../"

  include_groups = ["deployment", "networking"]
}
output "include_groups" {
  value = module.include_groups.actions
}
```

**Add actions but filter out writes**  
```hcl
module "filter_actions" {
  source = "../"

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
```
**Add groups but filter out services**
```hcl
module "exclude_services" {
  source = "../"

  include_groups = ["deployment", "networking"]

  exclude_services = [
    "route53",
  ]
}
output "exclude_services" {
  value = module.exclude_services.actions
}
```
