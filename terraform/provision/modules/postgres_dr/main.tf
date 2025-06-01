<<<<<<< HEAD

=======
resource "kubernetes_namespace" "postgres_dr" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_persistent_volume_claim" "pg_data" {
  metadata {
    name      = "pg-data"
    namespace = var.namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = var.storage_size
      }
    }

    storage_class_name = var.storage_class
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres-dr"
    namespace = var.namespace
  }

  spec {
    service_name = "postgres-dr"
    replicas     = 1

    selector {
      match_labels = {
        app = "postgres-dr"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres-dr"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = var.image

          env {
            name  = "POSTGRES_USER"
            value = var.username
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value = var.password
          }

          env {
            name  = "POSTGRES_DB"
            value = var.db_name
          }

          port {
            container_port = 5432
          }

          volume_mount {
            mount_path = "/var/lib/postgresql/data"
            name       = "pg-storage"
          }
        }

        volume {
          name = "pg-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.pg_data.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres-dr"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "postgres-dr"
    }

    port {
      port        = 5432
      target_port = 5432
    }

    type = "ClusterIP"
  }
}
>>>>>>> 101118e (fix: refactor directort)
