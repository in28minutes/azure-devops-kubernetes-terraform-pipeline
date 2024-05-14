# aws --version
# aws eks --region us-east-1 update-kubeconfig --name in28minutes-cluster
# Uses default VPC and Subnet. Create Your Own VPC and Private Subnets for Prod Usage.
# terraform-backend-state-in28minutes-123
# AKIA4AHVNOD7OOO6T4KI


terraform {
  backend "s3" {
    bucket = "mybucket" # Will be overridden from build
    key    = "path/to/my/key" # Will be overridden from build
    region = "us-east-1"
  }
}

resource "aws_default_vpc" "default" {

}

### Uncomment this section after cluster creation line numbers 25 to 31 ###
#data "aws_eks_cluster" "example" {
#   name = "in28minutes-cluster"
# }

#data "aws_eks_cluster_auth" "example" {
#  name = "in28minutes-cluster"
#}
### Uncomment this section after cluster creation ###

provider "kubernetes" {
### Uncomment this section after cluster creation line numbers 36 to 38###
#  host                   = data.aws_eks_cluster.example.endpoint
#  cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
#  token                  = data.aws_eks_cluster_auth.example.token
### Uncomment this section after cluster creation ###
}


module "in28minutes-cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = "in28minutes-cluster"
  cluster_version = "1.29"

  subnet_ids         = ["subnet-0ba16627", "subnet-02db6b4a", "subnet-e08479ba"] #CHANGE # Donot choose subnet from us-east-1e
  #subnets = data.aws_subnet_ids.subnets.ids
  vpc_id          = aws_default_vpc.default.id
  #vpc_id         = "vpc-1234556abcdef"

  //Newly added entry to allow connection to the api server
  //Without this change error in step 163 in course will not go away
  cluster_endpoint_public_access  = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

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
### Uncomment this section after cluster creation line numbers 88 to 115###
#resource "kubernetes_cluster_role_binding" "example" {
#  metadata {
#    name = "fabric8-rbac"
#  }
#  role_ref {
#    api_group = "rbac.authorization.k8s.io"
#    kind      = "ClusterRole"
#    name      = "cluster-admin"
#  }
#  subject {
#    kind      = "ServiceAccount"
#    name      = "default"
#    namespace = "default"
#  }
# }

#resource "kubernetes_secret" "example" {
#  metadata {
#    annotations = {
#      "kubernetes.io/service-account.name" = "default"
#    }
#
#    generate_name = "terraform-default-"
#  }
#
#  type                           = "kubernetes.io/service-account-token"
#  wait_for_service_account_token = true
# }
### Uncomment this section after cluster creation ###

# Needed to set the default region
provider "aws" {
  region  = "us-east-1"
}
