locals {
  partition = data.aws_partition.current.partition
  region = data.aws_region.current.name
  account = data.aws_caller_identity.current.account_id
}

//namespaces naming conventions
locals {
  namespace_family = {
    dashed = "${var.project_name}-${var.stack_name}"
    underscored = "${replace(var.project_name, "-", "_")}_${replace(var.stack_name, "-", "_")}"
    slashed = "${var.project_name}/${var.stack_name}"
  }
  namespace = {
    dashed = "${local.namespace_family.dashed}-%s"
    underscored = "${local.namespace_family.underscored}_%s"
    slashed = "${local.namespace_family.slashed}/%s"
    dashed_regional = "${local.namespace_family.dashed}-%s-${data.aws_region.current.name}"
    underscored_regional = "${local.namespace_family.underscored}_%s_${data.aws_region.current.name}"
    slashed_regional = "${local.namespace_family.slashed}/%s/${data.aws_region.current.name}"
  }
}

//assign namespaces for specific services
locals {
  component_name = {
    apigw = local.namespace.dashed
    cloudwatch = local.namespace.dashed
    log_group = "aws/lambda/${var.project_name}/${var.stack_name}/%s"
    ddb_table = local.namespace.underscored
    iam = local.namespace.dashed_regional
    lambda = local.namespace.dashed
    lambda_model = local.namespace.underscored
    s3 = local.namespace.dashed
  }
}

//paths to local source files
locals {
  path = {
    src = "../cmd/"
    bin = "../bin/"
    lambda = "../bin/%s.zip"
  }
}

//specifications for infra element config
locals {
  spec = {
    lambda_standard = {
      runtime = "go1.x"
      memory_size = 128
      timeout = 15
    }
    lambda_large = {
      runtime = "go1.x"
      memory_size = 256
      timeout = 15
    }
  }
}
