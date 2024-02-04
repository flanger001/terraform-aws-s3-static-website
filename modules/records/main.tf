variable "primary" {
  type = string
}

variable "domains" {
  type = list(string)
}

output "mapped_zones" {
  value = local.mapped_zones
}

output "zones" {
  value = local.zones
}

output "redirects" {
  value = [
    for domain in var.domains : domain if domain != var.primary
  ]
}

output "domains" {
  value = var.domains
}

locals {
  split_domains = [for domain in var.domains : split(".", domain)]
  _zones = toset([
    for domain in local.split_domains :
    join(".", slice(domain, length(domain) - 2, length(domain)))
    if length(domain) >= 2
  ])
  _mapped_zones = {
    for zone in local._zones :
    zone => [
      for domain in local.split_domains :
      join(".", domain) if join(".", slice(domain, length(domain) - 2, length(domain))) == zone
    ]
  }
  mapped_zones = {
    for zone, domains in local._mapped_zones :
    zone => {
      CNAME = [for domain in domains : domain if domain != zone],
      A     = [for domain in domains : domain if domain == zone]
    }
  }
  zones = flatten([
    for zone, record_types in local.mapped_zones :
    [
      for record_type, records in record_types :
      [
        for record in records :
        {
          "zone"        = zone,
          "record_type" = record_type
          "record"      = record
        }
      ]
    ]
  ])
}
