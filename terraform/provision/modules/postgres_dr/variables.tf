variable "namespace" {
  description = "PostgreSQL이 배포될 네임스페이스"
  default     = "postgresql"
}

variable "image" {
  description = "PostgreSQL Docker 이미지"
  default     = "postgres:14"
}

variable "username" {
  type        = string
  description = "PostgreSQL 사용자 이름"
}

variable "password" {
  type        = string
  sensitive   = true
  description = "PostgreSQL 비밀번호"
}

variable "db_name" {
  type        = string
  description = "PostgreSQL 기본 데이터베이스 이름"
}

variable "storage_size" {
  type        = string
  default     = "10Gi"
  description = "스토리지 크기"
}

variable "storage_class" {
  type        = string
  default     = "gp2"
  description = "스토리지 클래스 이름"
}
