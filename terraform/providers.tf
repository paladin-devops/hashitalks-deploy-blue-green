provider "consul" {
  address    = var.consul_address
  datacenter = "dc1"
}

provider "vault" {
  address = var.vault_address
}

provider "waypoint" {
  waypoint_addr = var.waypoint_address
  token         = var.waypoint_token
}