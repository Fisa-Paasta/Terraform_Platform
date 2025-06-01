variable "name" {
  description = "RDS 식별자 prefix"
  type        = string
}

variable "vpc_id" {
  description = "RDS가 속한 VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "RDS용 private subnet 리스트"
  type        = list(string)
}

variable "eks_cidr_blocks" {
  description = "EKS 노드에서 접근 가능한 CIDR (보안 그룹 ingress)"
  type        = list(string)
}

variable "db_name" {
  type        = string
  description = "RDS 데이터베이스 이름"
}

variable "username" {
  type        = string
  description = "DB master username"
  sensitive   = true
}

variable "password" {
  type        = string
  description = "DB master password"
  sensitive   = true
}

variable "engine_version" {
  type    = string
  default = "14.10"
}

variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}
