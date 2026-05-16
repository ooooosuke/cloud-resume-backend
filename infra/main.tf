# main.tf

# AWS Provider 設定 
provider "aws" {
  region = var.region
}

# 1. S3バケットの作成
resource "aws_s3_bucket" "resume_bucket" {
  bucket = "furuta-resume-prod-2026-unique" 
}

# 2. 静的サイトの設定 (index.htmlをルートに)
resource "aws_s3_bucket_website_configuration" "resume_config" {
  bucket = aws_s3_bucket.resume_bucket.id
  index_document {
    suffix = "index.html"
  }
}

# 3. CloudFront OAC (Origin Access Control)
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 4. CloudFront Distribution
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name              = aws_s3_bucket.resume_bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3-Origin"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Origin"

    forwarded_values {
      query_string = false
      cookies { forward = "none" }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# S3バケットポリシーの追加
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.resume_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.resume_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

#Terraform 状態管理用バケット
terraform {
  backend "s3" {
    bucket = "crc-s3-pred-tfstate-furuta" 
    key    = "backend/terraform.tfstate" 
    region = "ap-northeast-1"
  }
}