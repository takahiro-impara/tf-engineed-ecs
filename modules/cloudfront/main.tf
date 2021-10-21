
resource "aws_cloudfront_distribution" "this" {
  aliases             = [var.domain]
  enabled             = true
  http_version        = "http2"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  tags                = var.tagNames
  tags_all            = var.tagNames
  wait_for_deployment = true
  web_acl_id          = var.web_acl_id
  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = aws_cloudfront_cache_policy.this.id
    cached_methods = [
      "GET",
      "HEAD",
    ]
    compress    = true
    default_ttl = 0
    max_ttl     = 0
    min_ttl     = 0
    #origin_request_policy_id = "5e015dea-0a15-490f-88a1-af94b286a673"
    smooth_streaming       = false
    target_origin_id       = var.alb_domain_name
    viewer_protocol_policy = "https-only"
  }
  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = var.alb_domain_name
    origin_id           = var.alb_domain_name

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1",
        "TLSv1.1",
        "TLSv1.2",
      ]
    }
  }
  restrictions {
    geo_restriction {
      locations        = ["JP"]
      restriction_type = "whitelist"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }
}

resource "aws_cloudfront_cache_policy" "this" {
  name        = "cachepolicy-${var.tagNames["Name"]}"
  comment     = "cachepolicy-${var.tagNames["Name"]}"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
  }
}
