provider "aws" {
    region = "us-east-1"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_region" "current" {}

resource "aws_iam_role" "test" {
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_sagemaker_model" "test" {
  name               = "test-model"
  execution_role_arn = aws_iam_role.test.arn

  primary_container {
    # If you change aws region, please visit: https://docs.aws.amazon.com/sagemaker/latest/dg/sagemaker-algo-docker-registry-paths.html
    # to get the account of the public registry.
    image = "382416733822.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/kmeans:1"
  }
}

resource "aws_sagemaker_endpoint_configuration" "test" {
  name = "my-endpoint-config"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.test.name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }
}