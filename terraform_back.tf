terraform{
    backend "s3" {
      bucket = "k8-vproapp"
      key = "terraform/state/production.tfstate"
      region = "us-east-1"
      encrypt = false
    }
}
