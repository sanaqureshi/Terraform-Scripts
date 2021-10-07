resource "random_pet" "rs" {
  length = 2
}

resource "aws_api_gateway_rest_api" "api-gateway" {
  name = "${random_pet.rs.id}-api"
  endpoint_configuration {
   types = ["REGIONAL"]
 }
}

resource "aws_api_gateway_resource" "MyDemo" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  parent_id   = "${aws_api_gateway_rest_api.api-gateway.root_resource_id}"
  path_part   = "test"
}

resource "aws_api_gateway_method" "MyMethod" {
  rest_api_id   = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id   = "${aws_api_gateway_resource.MyDemo.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "MyIntegration" {
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  resource_id = "${aws_api_gateway_resource.MyDemo.id}"
  http_method = "${aws_api_gateway_method.MyMethod.http_method}"
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "api-deploy" {
  depends_on = [aws_api_gateway_integration.MyIntegration]
  rest_api_id = "${aws_api_gateway_rest_api.api-gateway.id}"
  stage_name = "test"
  variables = {
    "answer" = "42"
  }
}

resource "aws_cloudfront_distribution" "api_distribution" {
depends_on = [aws_api_gateway_integration.MyIntegration,aws_api_gateway_deployment.api-deploy]

  origin {
    domain_name = replace(replace("${aws_api_gateway_deployment.api-deploy.invoke_url}", "/^https?:\\/\\//", ""), "/\\/.*$/", "")
    origin_id   = "apigw"
    custom_origin_config {
		http_port              = 80
		https_port             = 443
		origin_protocol_policy = "https-only"
		origin_ssl_protocols   = ["TLSv1.2"]
	}
}

  enabled             = true

  default_cache_behavior {
   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
   cached_methods   = ["HEAD", "GET", "OPTIONS"]
   target_origin_id = "apigw"

   default_ttl = 0
	 min_ttl     = 0
	 max_ttl     = 0

   forwarded_values {
     query_string = true
     cookies {
       forward = "all"
     }
   }
   viewer_protocol_policy = "redirect-to-https"
 }

  ordered_cache_behavior {
   path_pattern     = "/test/*"
   allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
   cached_methods   = ["HEAD", "GET", "OPTIONS"]
   target_origin_id = "apigw"

   default_ttl = 0
	 min_ttl     = 0
	 max_ttl     = 0

   forwarded_values {
     query_string = true
     cookies {
       forward = "all"
     }
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
