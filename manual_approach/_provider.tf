variable "digitalocean_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.digitalocean_token}"
}

terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0.0"
    }
    local = {
      source = "hashicorp/local"
      version = ">= 2.0.0"
    }
  }
}
