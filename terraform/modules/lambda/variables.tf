variable "name" {
  type = string
}
variable "handler" {
  type    = string
  default = "index.lambda_handler"
}
variable "runtime" {
  type    = string
  default = "python3.11"
}
variable "filename" {
  type = string
}
variable "role_arn" {
  type = string
}

variable "environment" {
  type    = map(string)
  default = {}
}

variable "log_retention" {
  type    = number
  default = 14
}
