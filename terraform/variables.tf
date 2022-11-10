variable "docker_username" {
  type      = string
  sensitive = true
}

variable "docker_password" {
  type      = string
  sensitive = true
}

variable "consul_address" {
  type = string
}

variable "consul_dc" {
  type    = string
  default = "dc1"
}

variable "vault_address" {
  type = string
}

variable "waypoint_address" {
  type = string
}

variable "waypoint_token" {
  type      = string
  sensitive = true
}