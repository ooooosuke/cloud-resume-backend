# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1" # 東京リージョン
}

# CloudFront の証明書などで使うバージニアリージョン用
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}