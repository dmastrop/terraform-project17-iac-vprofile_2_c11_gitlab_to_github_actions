# https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.19.1"

  cluster_name = local.cluster_name
  # see main.tf file for locals block
  #cluster_version = "1.27"
  cluster_version = "1.27"
  #cluster_version = "1.30"

  vpc_id = module.vpc.vpc_id
  # this is from the vpc.tf file
  subnet_ids = module.vpc.private_subnets
  # this is from the vpc.tf file
  cluster_endpoint_public_access = true
  # this cluster endpoint will be used by kubeconfig file for kubectl access from the terminal, etc....

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  # create two node groups. Node group is basically like an auto-scaling group
  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "node-group-2"

      instance_types = ["t3.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
