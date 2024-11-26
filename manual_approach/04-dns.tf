# We need to create a DNS entry for the domain
#
#resource "digitalocean_domain" "loser" {
#  name = "m1l0js.com" # I would have to buy a domain name
#}
#
## Add a record to the domain
#resource "digitalocean_record" "www" {
#  domain = "${digitalocean_domain.m1l0js.name}"
#  type   = "A"
#  name   = "www"
#  ttl    = "10"
#  value  = "${digitalocean_loadbalancer.public.ip}"
#}
#
#