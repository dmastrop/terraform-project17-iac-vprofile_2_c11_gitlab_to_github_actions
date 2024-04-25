# keep these versions the same as they are pre-tested
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }

  backend "s3" {
    #bucket = "gitopsterrastate"
    bucket = "terraform-state-project17-vprofile-gitops"
    # if this backend is not specified then terraform.tfstate will be created locally
    # we will be running this on github actions, and github actions uses a runner container which will be destroyed after
    # terraform scripts executed. The tfstate will be removed with this, so need an external terraform state decoupled from execution on github.
    key = "terraform.tfstate"
    # this key will be created on the S3 bucket.
    #region = "us-east-2"
    region = "us-east-1"
  }

  # this is the miniumum version of terraform to use
  #required_version = "~> 1.6.3"

#### USE THIS ONE FOR staging and deployment
  required_version = "~> 1.6.6"

  #required_version = 1.6.6

#### REVERT to this to do the terraform init and terraform destroy from the VSCode when complete  
  #required_version = "~> 1.5.1"
  
}


#


