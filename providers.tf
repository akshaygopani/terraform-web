terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "ap-south-1"
}
provider "aws" {
  alias  = "west"
  region = "us-east-1"
}

