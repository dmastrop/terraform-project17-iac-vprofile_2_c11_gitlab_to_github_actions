provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
}

provider "aws" {
  region = var.region
  # see variables.tf for var.region
}

data "aws_availability_zones" "available" {}
# used in the vpc.tf in the slice function to specify the availability zones.
# This above will give a list of all the availablity zones 

locals {
  cluster_name = var.clusterName
  # see variables.tf for var.clusterName
}

##
##
###
