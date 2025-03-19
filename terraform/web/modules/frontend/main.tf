terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 2.7.0"
    }
  }
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

resource "aws_cloudfront_origin_access_control" "s3_origin_access_identity" {
  name = "${var.prefix}s3-origin-access-identity"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name}"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_origin_access_identity.id
  }

  # NOTE: Route 53 hosted zone is in another AWS account.
  #  Add the alias record manually in Route 53 before deploying this CloudFront distribution.
  #  Name: var.fqdn, Value: CloudFront distribution domain name (e.g. d1234567890.cloudfront.net)
  aliases = [var.fqdn]
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "My MyProjectWeb App CDN"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.bucket_name}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    function_association {
      event_type = "viewer-request"
      function_arn = var.basic_auth ? aws_cloudfront_function.basic_auth.arn : aws_cloudfront_function.trailing_slash_index.arn
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # NOTE: 
    #   - ACM does not currently support cross account access. (https://repost.aws/questions/QUxxewbu3iQjqQghS-xD5O4w/cf-distro-and-acm-certificate-in-different-account)
    #   - Configure ACM in the same account as this CloudFront distribution and
    #     create an alias record in Route 53 to point to the CloudFront distribution manually beforehands.
    # cloudfront_default_certificate = true
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.bucket
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "${var.prefix}basic-auth-function"
  runtime = "cloudfront-js-1.0"
  comment = "Basic Auth Function"

  publish = true
  code    = <<-EOF
    function handler(event) {
      var request = event.request;
      var headers = request.headers;
      var uri = request.uri;
      var username = 'admin';
      var password = 'your password';

      var authString = 'Basic ' + (username + ':' + password).toString('base64');

      if (typeof headers.authorization === 'undefined' || headers.authorization.value !== authString) {
        return {
          statusCode: 401,
          statusDescription: 'Unauthorized',
          headers: {
            'www-authenticate': { value: 'Basic' }
          }
        };
      }

      if (uri.endsWith('/')) {
          request.uri += 'index.html';
      } else if (!uri.includes('.')) {
          request.uri += '.html';
      }

      return request;
    }
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  error_document {
    key = "404.html"
  }

  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_function" "trailing_slash_index" {
  name    = "${var.prefix}trailing-slash-index-function"
  runtime = "cloudfront-js-1.0"
  comment = "Trailing Slash Index Function"

  publish = true
  code    = <<-EOF
    function handler(event) {
      var request = event.request;
      var headers = request.headers;
      var uri = request.uri;

      if (uri.endsWith('/')) {
          request.uri += 'index.html';
      } else if (!uri.includes('.')) {
          request.uri += '.html';
      }

      return request;
    }
  EOF

  lifecycle {
    create_before_destroy = true
  }
}
