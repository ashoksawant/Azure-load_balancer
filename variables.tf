variable "resource_group_name" {
  default = "1-4fc45b3a-playground-sandbox"
  type    = string
}

variable "env" {
  type = string

}
variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "client_id" {
  type      = string
  sensitive = true
}

variable "client_secret" {
  sensitive = true
}

variable "vnet_name" {
  default = "vnet1"
  type    = string

}
variable "subnet_name" {
  default = "subnet1"
  type    = string

}
variable "pub_name" {
  default = "pubip1"
  type    = string

}
variable "loadbalancer_name" {
  default = "loadbal"
  type    = string

}
variable "vmscale_set_name" {
  default = "myscaleset1"
  type    = string

}
variable "nsg_name" {
  default = "nsg"
  type    = string
}
variable "admin_password" {
  type      = string
  sensitive = true

}