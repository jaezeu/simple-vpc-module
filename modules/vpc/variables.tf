variable "name_prefix" {
  type    = string
  default = "" #Set either your name or something unique here
}

variable "cidr_block" {
  type    = string
  default = "" #Set either your name or something unique here
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "db_subnet_cidrs" {
  type    = list(string)
  default = []
}

variable "create_natgw" {
  type    = bool
  default = false
}