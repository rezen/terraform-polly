# terraform-polly

Generate read-only AWS IAM action lists (and a ready-to-use policy document) from
logical service **groups** — instead of hand-maintaining sprawling `Action` blocks.

The module starts from a curated set of read-only actions (`data/read_actions.yaml`),
lets you pull them in by group or service, add your own, and filter/exclude the rest.
Write actions (`Create`, `Delete`, `Update`, `Put`, …) and wildcards are stripped from
anything passed via `filter_actions`, so it's easy to feed in a broad list and get back
only the safe reads.

## Usage

```hcl
module "readonly" {
  source = "github.com/rezen/terraform-polly?ref=v0.1.0"

  include_groups = ["deployment", "networking"]
}

# Raw list of actions
output "actions" {
  value = module.readonly.actions
}

# Or attach the generated policy directly
resource "aws_iam_policy" "readonly" {
  name   = "readonly"
  policy = module.readonly.policy_json
}
```

## Available groups

| Group | Services |
|-------|----------|
| `compute` | ec2, lambda, eks, ecs, elasticbeanstalk, batch |
| `containers` | eks, ecs, ecr |
| `storage` | s3, elasticfilesystem, glue |
| `networking` | networkmanager, vpc-lattice, route53, apigateway |
| `database` | athena, elasticache, rds, redshift, es, dynamodb, docdb, keyspaces, neptune |
| `web` | cloudfront |
| `events` | sqs, sns, ses, firehose, events |
| `deployment` | cloudformation, codebuild, codepipeline, codecommit |
| `identity` | iam, identitystore |
| `governance` | sso, securityhub, config, cloudtrail, identitystore |
| `monitoring` | cloudtrail, cloudwatch, grafana, logs |
| `security` | securityhub, secretsmanager, kms |

If a group references a service that isn't in `data/read_actions.yaml`, the module
falls back to `<service>:Describe*`, `<service>:List*`, and `<service>:Get*`.

## Examples

**Include specific groups**
```hcl
module "include_groups" {
  source         = "../"
  include_groups = ["deployment", "networking"]
}
```

**Add actions but filter out writes and wildcards**
```hcl
module "filter_actions" {
  source = "../"

  filter_actions = [
    "s3:Get*",                 # dropped: wildcard
    "s3:*",                    # dropped: wildcard
    "vpc-lattice:DeleteRule",  # dropped: write
    "apprunner:ListVpcConnectors",
  ]
  # => keeps only "apprunner:ListVpcConnectors"
}
```

**Include groups but exclude a service**
```hcl
module "exclude_services" {
  source           = "../"
  include_groups   = ["deployment", "networking"]
  exclude_services = ["route53"]
}
```

See [`examples/`](./examples) for runnable configurations.

## How filtering works

The final action list is built in this order:

1. Expand `include_groups` into actions.
2. Add `include_actions` verbatim.
3. Add `filter_actions` **after** removing wildcards and write verbs.
4. Remove anything in `exclude_actions`.
5. Remove any action whose service is in `exclude_services`.
6. Sort and de-duplicate.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.4 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| include_groups | Named permission groups whose read actions should be included. | `list(string)` | `[]` | no |
| include_actions | Fully-qualified actions to add verbatim, in addition to any from `include_groups`. | `list(string)` | `[]` | no |
| filter_actions | Candidate actions kept only after dropping wildcards and write actions. | `list(string)` | `[]` | no |
| exclude_actions | Fully-qualified actions to drop from the final list. | `list(string)` | `[]` | no |
| exclude_services | Service prefixes to drop from the final list. | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| actions | Sorted, de-duplicated list of IAM actions produced from the inputs. |
| policy_json | An IAM policy document (JSON) allowing the generated actions on all resources. |
<!-- END_TF_DOCS -->

## License

MIT — see [LICENSE](./LICENSE).
