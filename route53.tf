#Importa a zona de DNS primária wellingtonvidaleal.com.br definida pelo outro subprojeto do terraform "route53-zone"
data "aws_route53_zone" "primary" {
  name         = "wellingtonvidaleal.com.br."
  private_zone = false
}

#Define que o registro de DNS wellingtonvidaleal.com.br aponta para o load balancer da aplicação do Wordpress
resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "wellingtonvidaleal.com.br"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}

#Define que o CNAME www.wellingtonvidaleal.com.br aponta para a registro root
resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "www.wellingtonvidaleal.com.br"
  type    = "CNAME"
  ttl     = 300
  records = [aws_route53_record.root.name]
}

#Define que o registro de DNS monitoring.wellingtonvidaleal.com.br aponta para o IP público da instância do Prometheus/Grafana
resource "aws_route53_record" "monitoring" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "monitoring.wellingtonvidaleal.com.br"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.prometheus.public_ip]
}