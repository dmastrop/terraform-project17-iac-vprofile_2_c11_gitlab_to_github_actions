variable "region" {
  description = "AWS region"
  type        = string
  #default     = "us-east-2"
  default = "us-east-1"
}

variable "clusterName" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "project17-eks-vprofile"
}
