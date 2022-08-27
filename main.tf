locals {
  s3_name = "${element(split(".", var.hosted_zone), 0)}-com-site"
  www     = "www.${var.domain}"
}

terraform {
  required_version = "=0.12.24"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.0"
}

data "aws_route53_zone" "public" {
  name         = var.hosted_zone
  private_zone = false
}


resource "aws_s3_bucket" "site_bucket" {
  bucket = local.s3_name
  acl    = "public-read"

  versioning {
    enabled = var.versioning
  }

  website {
    index_document = var.index_page
    error_document = var.error_page
  }
}

resource "aws_s3_bucket" "website_redirect" {
  bucket        = "${local.s3_name}-redirect"
  acl           = "public-read"
  force_destroy = true

  website {
    redirect_all_requests_to = "https://${var.domain}"
  }
}

resource "aws_s3_bucket_policy" "update_website_root_bucket_policy" {
  bucket = aws_s3_bucket.site_bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PublicRead",
  "Statement": [
    {
      "Sid": "AllowCloudFrontOriginAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity_website.iam_arn}"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.site_bucket.arn}/*",
        "${aws_s3_bucket.site_bucket.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"

  subject_alternative_names = [var.domain]
}

resource "aws_route53_record" "wildcard_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.public.zone_id
  records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "wildcard_cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.wildcard_validation.fqdn]
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity_website" {
  comment = "CloudfrontOriginAccessIdentity - ${var.hosted_zone}"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    domain_name = aws_s3_bucket.site_bucket.bucket_regional_domain_name
    origin_id   = "origin-${aws_s3_bucket.site_bucket.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity_website.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_page

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "origin-${aws_s3_bucket.site_bucket.id}"
    min_ttl                = 0
    default_ttl            = 60
    max_ttl                = 360
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [var.domain]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_cloudfront_distribution" "cdn_redirect" {
  enabled     = true
  price_class = "PriceClass_All"
  aliases     = [local.www]

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_redirect.id}"
    domain_name = aws_s3_bucket.website_redirect.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_redirect.id}"
    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.www
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.cdn_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}
