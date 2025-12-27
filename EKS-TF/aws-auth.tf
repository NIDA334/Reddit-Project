data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<EOF
- rolearn: arn:aws:iam::568298704251:role/Nida-iam-role
  username: admin
  groups:
    - system:masters
EOF
  }
}
