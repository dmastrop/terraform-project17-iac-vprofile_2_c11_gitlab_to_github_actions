# https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "vprofile-eks"

  cidr = "172.20.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
  # slice function is using data in main.tf
  # the above slice will give a list of all the availability zones in the region (us-east-1 for my setup)
  # we only want three of them
  # alternatively can specify azs manually in brackets, for example:
  #  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  private_subnets = ["172.20.1.0/24", "172.20.2.0/24", "172.20.3.0/24"]
  public_subnets  = ["172.20.4.0/24", "172.20.5.0/24", "172.20.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  # we don't want three per the azs above. Keep it to one for testing.
  enable_dns_hostnames = true


  # tags for subnets are required in EKS as part of k8s.
  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}
