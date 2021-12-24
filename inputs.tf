variable "default_root_object" {
  description = "The default object for CloudFront to return"
  default     = "index.html"
}

variable "enable_ipv6" {
  description = "Whether or not to enable ipv6"
}

variable "hosted_zone" {
  description = "The hosted zone to deploy the site to"
}

variable "max_ttl" {
  description = "Maximum ttl for cache"
  default     = 3600
}

variable "min_ttl" {
  description = "Minimum ttl for cache"
  default     = 0
}

variable "origin_access_identity_comment" {
  description = "The comment to give the origin access identity"
}

variable "private_hosted_zone" {
  description = "Is the hosted zone private?"
}

variable "resource_tag_map" {
  description = "A map of tags to use on resources"
  type        = "map"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket that contains the static site"
}

variable "validation_method" {
  description = "The validation method to use for the ACM certificate (DNS, EMAIL, or NONE)"
}
