variable "first_name" {
  description = "This does"
  type = string
  default = null
}
variable "last_name" {
  description = "This does"
  type = string
  default = null
}
variable "email" {
  description = "This does"
  type = string
  default = null
}
variable "suspended" {
  description = "This does"
  type = bool
  default = false
}
variable "role_name" {
  description = "This does"
  type = string
  default = null
}
variable "users" {
  description = "this does "
  type = list(map(string))
  default = [{}]
}

