output "postgres_dr_service" {
  value = kubernetes_service.postgres.metadata[0].name
}
