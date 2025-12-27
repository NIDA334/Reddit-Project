provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "eks" {
  name = "Reddit-EKS-Cluster"  # <--- put your existing cluster name here
}

data "aws_eks_cluster_auth" "eks" {
  name = data.aws_eks_cluster.eks.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.eks.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.eks.token
}
