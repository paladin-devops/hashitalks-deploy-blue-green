provider "consul" {
  address    = "localhost:8500"
  datacenter = "dc1"
}

provider "vault" {
  address = "http://192.168.1.242:8200"
}

provider "waypoint" {
  waypoint_addr = var.waypoint_address
  token         = var.waypoint_token
}