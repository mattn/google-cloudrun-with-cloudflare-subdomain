terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    ko = {
      source = "ko-build/ko"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

provider "google" {
  project = var.google_cloud_project
  region  = var.google_cloud_region
}

variable "google_cloud_project" {}

variable "google_cloud_region" {}

variable "google_cloud_run_service" {}

variable "google_cloud_run_repo" {}

provider "ko" {
  repo = var.google_cloud_run_repo
}

resource "ko_build" "my-app" {
  importpath = "."
}

resource "google_cloud_run_service" "default" {
  name     = var.google_cloud_run_service
  location = var.google_cloud_region

  template {
    spec {
      containers {
        image = ko_build.my-app.image_ref
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_domain_mapping" "custom_domain" {
  name = "${var.cloudflare_subdomain}.${var.cloudflare_domain}"
  location = google_cloud_run_service.default.location

  metadata {
    namespace = var.google_cloud_project
  }

  spec {
    route_name = google_cloud_run_service.default.name
  }
}

output "url" {
  value = "https://${google_cloud_run_domain_mapping.custom_domain.name}"
}
