variable "include_groups" {
  type    = list(string)
  default = []
}

variable "only_services" {
  type    = list(string)
  default = []

}

variable "exclude_services" {
  type    = list(string)
  default = []

}

variable "exclude_actions" {
  type    = list(string)
  default = []
}

variable "include_actions" {
  type    = list(string)
  default = []
}

variable "filter_actions" {
  type    = list(string)
  default = []
}
