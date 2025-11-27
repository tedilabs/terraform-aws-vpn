terraform {
  required_version = ">= 1.12"

  required_providers {
    assert = {
      source  = "hashicorp/assert"
      version = ">= 0.16"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.12"
    }
  }
}
