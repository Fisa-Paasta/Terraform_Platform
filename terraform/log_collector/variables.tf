<<<<<<< HEAD
variable "region" {
  type = string
}

variable "resource_log_groups" {
  type = list(string)
}
=======
variable "region" {
  type        = string
  description = "AWS region to deploy resources"
}

variable "resource_log_groups" {
  type        = list(string)
  description = "List of CloudWatch log groups to subscribe Lambda to"
}
>>>>>>> 101118e (fix: refactor directort)
