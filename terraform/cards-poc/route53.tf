resource "aws_route53_record" "cards" {
  name = aws_api_gateway_domain_name.cards.domain_name
  type = "A"
  zone_id = var.api_zone_id

  alias {
    evaluate_target_health = true
    name = aws_api_gateway_domain_name.cards.regional_domain_name
    zone_id = aws_api_gateway_domain_name.cards.regional_zone_id
  }
}