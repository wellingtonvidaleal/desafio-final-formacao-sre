#Define a geração do certificado wildcard válido pela própria AWS, e define o método de validação por DNS
resource "aws_acm_certificate" "this" {
  domain_name               = "wellingtonvidaleal.com.br"
  validation_method         = "DNS"
  subject_alternative_names = ["*.wellingtonvidaleal.com.br"]

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.wordpress_tags,
    {
      Name = "${var.environment}-wordpress"
    }
  )
}

#Define o registro de validação
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

#Define o recurso de validação do certificado
resource "aws_acm_certificate_validation" "this" {
  certificate_arn = aws_acm_certificate.this.arn

  validation_record_fqdns = [
    for r in aws_route53_record.validation :
    r.fqdn
  ]
}