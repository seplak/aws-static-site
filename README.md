# aws-static-site

A small AWS S3 + CDN module for a static site on AWS.

## Requirements

No requirements.

## Providers

| Name                                             | Version |
| ------------------------------------------------ | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a     |

## Modules

No modules.

## Resources

| Name                                                                                                                                                           | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate)                                        | resource    |
| [aws_acm_certificate_validation.validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate_validation)            | resource    |
| [aws_cloudfront_distribution.cdn_s3_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution)         | resource    |
| [aws_cloudfront_origin_access_identity.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource    |
| [aws_route53_record.alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record)                                         | resource    |
| [aws_route53_zone.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone)                                         | data source |
| [aws_s3_bucket.static_site_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket)                                   | data source |

## Inputs

| Name                                                                                                                        | Description                                                                | Type     | Default        | Required |
| --------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------- | -------------- | :------: |
| <a name="input_default_root_object"></a> [default_root_object](#input_default_root_object)                                  | The default object for CloudFront to return                                | `string` | `"index.html"` |    no    |
| <a name="input_enable_ipv6"></a> [enable_ipv6](#input_enable_ipv6)                                                          | Whether or not to enable ipv6                                              | `any`    | n/a            |   yes    |
| <a name="input_hosted_zone"></a> [hosted_zone](#input_hosted_zone)                                                          | The hosted zone to deploy the site to                                      | `any`    | n/a            |   yes    |
| <a name="input_max_ttl"></a> [max_ttl](#input_max_ttl)                                                                      | Maximum ttl for cache                                                      | `number` | `3600`         |    no    |
| <a name="input_min_ttl"></a> [min_ttl](#input_min_ttl)                                                                      | Minimum ttl for cache                                                      | `number` | `0`            |    no    |
| <a name="input_origin_access_identity_comment"></a> [origin_access_identity_comment](#input_origin_access_identity_comment) | The comment to give the origin access identity                             | `any`    | n/a            |   yes    |
| <a name="input_private_hosted_zone"></a> [private_hosted_zone](#input_private_hosted_zone)                                  | Is the hosted zone private?                                                | `any`    | n/a            |   yes    |
| <a name="input_resource_tag_map"></a> [resource_tag_map](#input_resource_tag_map)                                           | A map of tags to use on resources                                          | `map`    | n/a            |   yes    |
| <a name="input_s3_bucket_name"></a> [s3_bucket_name](#input_s3_bucket_name)                                                 | The name of the S3 bucket that contains the static site                    | `any`    | n/a            |   yes    |
| <a name="input_validation_method"></a> [validation_method](#input_validation_method)                                        | The validation method to use for the ACM certificate (DNS, EMAIL, or NONE) | `any`    | n/a            |   yes    |

## Outputs

No outputs.
