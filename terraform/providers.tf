provider "consul" {
  address    = var.consul_address
  datacenter = "dc1"
  token      = var.consul_token
}

provider "vault" {
  address = var.vault_address
  token   = var.vault_token
}

provider "waypoint" {
  waypoint_addr = var.waypoint_address
  token         = var.waypoint_token
}