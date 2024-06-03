
data "aws_route53_zone" "public_domain_name" {
  name         = local.public_domain_name
}


resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.public_domain_name.zone_id
  name    = local.public_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.vscan-network-alb.dns_name
    zone_id                = aws_lb.vscan-network-alb.zone_id
    evaluate_target_health = true
  }
}