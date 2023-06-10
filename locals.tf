locals {
  write_verbs = [
    "Delete",
    "Accept",
    "Associate",
    "Remove",
    "Create",
    "Attach",
    "Update",
    "Put",
    "Enable",
    "Reject",
    "Revoke",
    "Peer",
  ]

  # Regex for actions associated with writes
  write_regex = "\\:(?i:Batch|Un|Re)?(?i:${join("|", local.write_verbs)})"

  # Some subsets of functionality are nicely encapsulated with an alias
  aliases = {
    "vpc" : [
      "ec2:DescribeVpc*",
    ]
  }

  # Defined groups which are used by vars generate policies
  groups = {
    compute = {
      services = [
        "ec2",
        "lambda",
        "eks",
        "ecs",
        "elasticbeanstalk",
        "batch",
      ]
    }

    containers = {
      services = [
        "eks",
        "ecs",
        "ecr"
      ]
    }

    storage = {
      services = [
        "s3",
        "elasticfilesystem",
        "glue",
      ]
    }
    networking = {
      services = [
        "networkmanager",
        "vpc-lattice",
        "route53",
        "apigateway"
      ]
      actions = [
        "ec2:DescribeVpc*",
      ]
    }
    database = {
      services = [
        "athena",
        "elasticache",
        "rds",
        "redshift",
        "es",
        "dynamodb",
        "docdb",
        "keyspaces",
        "neptune",
      ]
    }

    web = {
      services = [
        "cloudfront",
      ]
    }

    events = {
      services = [
        "sqs",
        "sns",
        "ses",
        "firehose",
        "events",
      ]
    }

    deployment = {
      services = [
        "cloudformation",
        "codebuild",
        "codepipeline",
        "codecommit",
      ]
    }

    identity = {
      services = [
        "iam",
        "identitystore",
      ]
    }
    governance = {
      services = [
        "sso",
        "securityhub",
        "config",
        "cloudtrail",
        "identitystore",
      ]
    }
    monitoring = {
      services = [
        "cloudtrail",
        "cloudwatch",
        "grafana",
        "logs",
      ]
    }

    security = {
      services = [
        "securityhub",
        "secretsmanager",
        "kms",
      ]
    }
  }


  read_actions = yamldecode(file("${path.module}/data/read_actions.yaml"))

  # For every service get actions
  by_service = {
    for action in local.read_actions : split(":", action)[0] => action...
  }

  # For getting actions by group
  by_group_prepped = {
    for name, config in local.groups : name => [for s in lookup(config, "services", []) : lookup(local.by_service, s, [
      "${s}:Describe*",
      "${s}:List*",
      "${s}:Get*",
    ])]...
  }
  by_group = {
    for name, value in local.by_group_prepped : name => flatten(value)
  }

  filtered_policies  = [for a in var.filter_actions : a if length(try(regex("\\:(\\*|[A-Za-z]+\\*)", a), [])) < 1 && length(try(regex(local.write_regex, a), [])) < 1]
  group_actions      = flatten([for g in var.include_groups : lookup(local.by_group, g, [])])
  before_excludes    = sort(distinct(concat(local.group_actions, var.include_actions, local.filtered_policies)))
  excluding_actions  = [for a in local.before_excludes : a if !contains(var.exclude_actions, a)]
  excluding_services = [for a in local.excluding_actions : a if !contains(var.exclude_services, split(":", a)[0])]
  final              = local.excluding_services
}

