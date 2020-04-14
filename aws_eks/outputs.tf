###############################################################################
# OUTPUTS
###############################################################################

output "aws_auth" {
  description = "terraform output aws_auth | kubectl apply -f -"
  value     = local.config_map_aws_auth
  sensitive = true
}
output "kubeconfig" {
  description = "terraform output kubeconfig > ~/.kube/config"
  value     = local.kubeconfig
  sensitive = true
}
output "cluster_name" {
  value = var.cluster_name
}
output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}
output "certificate_authority" {
  value = aws_eks_cluster.cluster.certificate_authority.0.data
}
output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}


# output "eks_sdm_cli" {
#   value     = local.sdm_add_cli
#   sensitive = true
# }
# output "eks_add_to_sdm" {
#   value = "eval $(terraform output eks_sdm_cli)"
# }