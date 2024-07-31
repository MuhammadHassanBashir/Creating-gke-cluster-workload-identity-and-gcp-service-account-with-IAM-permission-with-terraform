terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.82.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.11.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "= 1.14.0"
    }
  }
}

provider "google" {
  project     = var.projectName
  region      = var.region
  credentials = file("/creds/world-learning-400909/secret.json")
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

resource "google_service_account" "workload_identity_user_sa" {
  account_id   = "gke-areez"
  display_name = "My Service Account"
}

data "google_client_config" "current" {}

resource "google_project_iam_member" "monitoring_role" {
  project = data.google_client_config.current.project
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "apigateway_admin_role" {
  project = data.google_client_config.current.project
  role    = "roles/apigateway.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "cloudfunctions_admin_role" {
  project = data.google_client_config.current.project
  role    = "roles/cloudfunctions.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "discoveryengine_admin_role" {
  project = data.google_client_config.current.project
  role    = "roles/discoveryengine.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "secretmanager_admin_role" {
  project = data.google_client_config.current.project
  role    = "roles/secretmanager.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "serviceaccount_tokencreator_role" {
  project = data.google_client_config.current.project
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "storage_admin_role" {
  project = data.google_client_config.current.project
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "storage_objectadmin_role" {
  project = data.google_client_config.current.project
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "aiplatform_admin_role" {
  project = data.google_client_config.current.project
  role    = "roles/aiplatform.admin"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "aiplatform_user_role" {
  project = data.google_client_config.current.project
  role    = "roles/aiplatform.user"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "pubsub_publisher_role" {
  project = data.google_client_config.current.project
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "pubsub_subscriber_role" {
  project = data.google_client_config.current.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "serviceusage_consumer_role" {
  project = data.google_client_config.current.project
  role    = "roles/serviceusage.serviceUsageConsumer"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_project_iam_member" "workloadidentity_user_role" {
  project = data.google_client_config.current.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${google_service_account.workload_identity_user_sa.email}"
}

resource "google_container_cluster" "default" {
  name = "test-cluster"
  location = var.location  # Set the zone for the cluster
  initial_node_count = 1  # Set a valid initial node count

  workload_identity_config {
    workload_pool = "${data.google_client_config.current.project}.svc.id.goog"
  }
}

resource "google_container_node_pool" "default" {
  name       = "pool"
  cluster    = google_container_cluster.default.id
  node_count = 1
  node_config {
    image_type = "COS_CONTAINERD"

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

resource "kubernetes_service_account" "ksa" {                 # i have check with this resource block is not working. We can do with with gcloud command as well..
  metadata {
    name      = "gke-areez"
    namespace = "default"
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.workload_identity_user_sa.email
    }
  }
}

resource "google_project_iam_member" "workload_identity_role" {
  project = data.google_client_config.current.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${var.projectName}.svc.id.goog[default/gke-areez]"
}
