terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.70.0"
    }
  }
  required_version = ">= 0.13.7, < 2.0.0"
}
