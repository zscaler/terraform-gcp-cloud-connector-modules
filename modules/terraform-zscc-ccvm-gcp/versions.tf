terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.11.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.1"
    }
  }

  required_version = ">= 0.13.7, < 2.0.0"
}
