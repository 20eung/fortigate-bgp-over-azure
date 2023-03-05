#variables
variable "hostname" {
  description = "(required)"
  type        = string
}

variable "token" {
  description = "(required)"
  type        = string
}

variable "insecure" {
  description = "(required)"
  type        = string
}

variable "cabundlefile" {
  description = "(required)"
  type        = string
}