locals {
  domain_name = trim(var.hosted_zone, ".")
}

###########################################################
# Data
###########################################################

data "aws_route53_zone" "public" {
  name         = var.hosted_zone
  private_zone = var.private_hosted_zone
}

data "aws_s3_bucket" "static_site_bucket" {
  bucket = var.s3_bucket_name
}

###########################################################
# CloudFront
###########################################################

resource "aws_cloudfront_distribution" "cdn_s3_distribution" {
  default_cach_behavior {
    allowed_methods = ["GET", "HEAD", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    cookies {
      forward = "none"
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl

  }

  default_root_object = var.default_root_object
  enabled             = true
  is_ipv6_enabled     = var.enable_ipv6

  tags = var.resource_tags

  origin {
    domain_name = data.aws_s3_bucket.static_site_bucket.bucket_regional_domain_name
    origin_id   = var.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
  }
}

resource "aws_cloudfront_origin_access_identity" "default" {
  comment = var.origin_access_identity_comment
}

resource "aws_acm_certificate" "cert" {
  domain_name        = local.domain_name
  validateion_method = var.validation_method

  tags = var.resource_tags
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.alias.fqdn]
}

resource "aws_route53_record" "alias" {
  zone_id = aws_route53_zone.public.id
  name    = "www.${local.domain_name}"
  type    = "A"
  ttl     = 300
  records = data.aws_route53_zone.public.name_servers
}
