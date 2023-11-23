terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 1.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 1.2"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9.0"
    }
  }
}
