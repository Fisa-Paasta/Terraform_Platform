variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

variable "project_name" {
  description = "태그용 프로젝트 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
}

variable "azs" {
  description = "사용할 AZ 목록"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public 서브넷 목록"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private 서브넷 목록"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS 클러스터 이름 (서브넷 태깅용)"
  type        = string
}
