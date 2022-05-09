//TEST COMMENT
module "cards-poc" {
  source = "./cards-poc"
  project_name = "sandbox"
  stack_name = "cards-poc"
  api_dns_name = var.api_dns_name
  api_zone_id = var.api_zone_id
  api_tls_cert_arn = var.api_tls_cert_arn
}