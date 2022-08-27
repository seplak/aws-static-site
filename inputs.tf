variable "aws_region" {
  description = "The AWS region to use"
  default     = "us-east-1"
}

variable "domain" {
  description = "The domain to host the site at"
}

variable "error_page" {
  description = "The error page of the site"
  default     = "error.html"
}

variable "hosted_zone" {
  description = "The hosted zone to use"
}

variable "index_page" {
  description = "The index page of the site"
  default     = "index.html"
}

variable "versioning" {
  description = "Whether or not to enable versioning on the site S3 bucket"
  default     = true
}

