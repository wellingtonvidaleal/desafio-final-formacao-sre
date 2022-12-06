# variable "records" {
#   default = {
#     www = {
#       name   = "www.wellingtonvidaleal.com.br"
#       record = "wellingtonvidaleal.com.br"
#       ttl    = 600
#       type   = "CNAME"
#     }
#     monitoring = {
#       name   = "monitoring.wellingtonvidaleal.com.br"
#       record = "monitoring-abc1234.us-east-1.elb.amazonaws.com"
#       ttl    = 600
#       type   = "CNAME"
#     }
#   }
# }

# resource "aws_route53_record" "all_records" {
#   for_each = var.records

#   zone_id = aws_route53_zone.primary.zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = each.value.ttl
#   records = [each.value.record]
# }

# variables "temp" {
#   default = {
#     "*.wellingtonvidaleal.com.br" = {
#       name   = "akslakslk"
#       record = "anabnsbansbas"
#       type   = "CNAME"
#     }
#     "wellingtonvidaleal.com.br" = {
#       name   = "akslakslk"
#       record = "anabnsbansbas"
#       type   = "CNAME"
#     }
#   }
# }


resource "aws_acm_certificate" "this" {
  domain_name               = "wellingtonvidaleal.com.br"
  validation_method         = "DNS"
  subject_alternative_names = ["*.wellingtonvidaleal.com.br"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true

  zone_id = data.aws_route53_zone.primary.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for r in aws_route53_record.validation :
    r.fqdn
  ]
}

/* output "validation_00_records" {
  value = aws_route53_record.validation
}

output "validation_01_fqdns" {
  value = [
    for r in aws_route53_record.validation :
    r.fqdn
  ]
} */

# aws_route53_record.www.zone_id

# aws_route53_record.validation["*.wellingtonvidaleal.com.br"].name

# terraform state show aws_route53_record.validation["wellingtonvidaleal.com.br"]

