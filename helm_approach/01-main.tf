resource "digitalocean_kubernetes_cluster" "m1l0js" {
  name    = "m1l0js"
  region  = "lon1"
  version = "1.31.1-do.4"

  node_pool {
    name       = "m1l0js-nodes"
    size       = "s-2vcpu-2gb"
    node_count = 3
    tags = ["m1l0js-nodes"]
  }
}
