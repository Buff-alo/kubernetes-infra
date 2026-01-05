
terraform {
  required_providers {
    # AWS Provider 
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0" 
    }

    # Google Provider 
    google = {
      source  = "hashicorp/google"
      version = "~> 7.6" 
    }

    # OCI Provider 
    oci = {
      source  = "oracle/oci"  
      version = "~> 7.0"      
    }
  }
}


provider "aws" {
  region = var.aws_region
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "oci" {
  tenancy_ocid     = var.oci_tenancy_ocid
  user_ocid        = var.oci_user_ocid
  fingerprint      = var.oci_fingerprint
  private_key_path = var.oci_private_key_path
  region           = var.oci_region 
}