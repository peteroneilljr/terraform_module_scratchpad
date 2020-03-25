#################
# Variables
#################

  variable "eks_cluster_name" {}
  variable "cluster_version" {}
  variable "subnets" {}
  variable "vpc_id" {}
  variable "vpc_igw" {}
  variable "vpc_cidr" {}
  variable "eks_cidr_block" {}
  variable "default_tags" {}
  variable "region" {
    default = "us-west-2"
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
    - rolearn: ${aws_iam_role.eks-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH

  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
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
        - "${var.eks_cluster_name}"
KUBECONFIG

  sdm_add_cli = <<SDMCLI
"sdm admin clusters add amazoneks \
--name ${aws_eks_cluster.eks.name} \
--certificate-authority \"${aws_eks_cluster.eks.certificate_authority.0.data}\" \
--cluster-name ${aws_eks_cluster.eks.name} \
--endpoint ${aws_eks_cluster.eks.endpoint} \
--region ${var.region} \
${aws_eks_cluster.eks.name}"
SDMCLI


}
