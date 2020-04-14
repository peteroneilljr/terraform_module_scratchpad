#################
# Variables
#################
variable "cluster_name" {}
variable "eks_version" {}
variable "vpc_id" {}
# variable "vpc_igw" {}
# variable "vpc_cidr" {}
# variable "eks_cidr_block" {}
variable "tags" {}
# variable "region" {
#   default = "us-west-2"
# }
variable "public_subnets" {
  default = []
}
variable "private_subnets" {
  default = []
}



###############################################################################
# locals
###############################################################################
locals {
  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.managed_workers.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.cluster.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG

}
