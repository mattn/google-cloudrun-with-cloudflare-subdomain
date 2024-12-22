provider "cloudflare" {
    email   = var.cloudflare_email
    api_key = var.cloudflare_api_key
}

variable "cloudflare_email" {
    default = "your-email"
}

variable "cloudflare_api_key" {
    default = "your-api-key"
}

variable "cloudflare_domain" {
    default = "your-domain"
}

variable "cloudflare_subdomain" {
    default = "your-subdomain"
}

variable "cloudflare_zone_id" {
    default = "your-zone-id"
}

resource "cloudflare_record" "google_cloud_run_cname" {
  zone_id = var.cloudflare_zone_id
  name    = var.cloudflare_subdomain
  content = "ghs.googlehosted.com."
  type    = "CNAME"
  ttl     = 3600
  proxied = false

  depends_on = [
    google_cloud_run_service.default,
  ]
}

resource "cloudflare_page_rule" "acme_challenge_bypass" {
  zone_id = var.cloudflare_zone_id
  target  = "${var.cloudflare_subdomain}.${var.cloudflare_domain}/.well-known/acme-challenge/*"
  actions {
    automatic_https_rewrites = "off"
    browser_check            = "off"
    cache_level              = "bypass"
    security_level           = "essentially_off"
  }

  depends_on = [
    cloudflare_record.google_cloud_run_cname,
  ]
}
