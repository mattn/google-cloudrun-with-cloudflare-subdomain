terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
    ko = {
      source  = "ko-build/ko"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

variable "project" {
  default = "my-cloud-192102"
}

variable "region" {
  default = "asia-northeast1"
}

variable "service" {
  default = "tf-ko-example"
}

provider "ko" {}

resource "ko_build" "example" {
  importpath = "github.com/ko-build/terraform-provider-ko/cmd/test"
}

resource "google_cloud_run_service" "default" {
  name     = var.service
  location = var.region

  template {
    spec {
      containers {
        image = ko_build.example.image_ref
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

output "url" {
  value = google_cloud_run_service.default.status[0].url
}
