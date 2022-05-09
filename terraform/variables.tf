variable "api_dns_name" {
    description = "DNS name of created API"
}

variable "api_zone_id" {
    description = "Id of Hosted Zone for DNS alias"
}

variable "api_tls_cert_arn" {
    description = "ARN of TLS certificate to be used to host https traffic"
}