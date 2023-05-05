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

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.default.id
}


provider "kubernetes" {
  //>>Uncomment this section once EKS is created - Start
  host                   = data.aws_eks_cluster.cluster.endpoint #module.in28minutes-cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  //>>Uncomment this section once EKS is created - End
}

module "in28minutes-cluster" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "in28minutes-cluster"
  cluster_version = "1.23"
  subnet_ids         = ["subnet-0ba16627", "subnet-02db6b4a", "subnet-e08479ba"] #CHANGE # Donot choose subnet from us-east-1e
  vpc_id          = aws_default_vpc.default.id

  //Newly added entry to allow connection to the api server
  //Without this change error in step 163 in course will not go away
  cluster_endpoint_public_access  = true

# EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t2.small", "t2.medium"]
  }

  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 10
      desired_size = 1

      instance_types = ["t2.medium"]
    }
  }
}

//>>Uncomment this section once EKS is created - Start
 data "aws_eks_cluster" "cluster" {
   name = "in28minutes-cluster" #module.in28minutes-cluster.cluster_name
 }

data "aws_eks_cluster_auth" "cluster" {
  name = "in28minutes-cluster" #module.in28minutes-cluster.cluster_name
}


# We will use ServiceAccount to connect to K8S Cluster in CI/CD mode
# ServiceAccount needs permissions to create deployments 
# and services in default namespace
resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "fabric8-rbac"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "default"
  }
}
//>>Uncomment this section once EKS is created - End

# Needed to set the default region
provider "aws" {
  region  = "us-east-1"
}