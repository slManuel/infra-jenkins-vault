terraform {
  backend "s3" {
    bucket       = "tfstate-prueba-cuscatlan-oct2026-jose-manuel-solis"
    key          = "jenkins-vault/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
