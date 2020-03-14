###############################################################################
# OUTPUTS
###############################################################################

output "eks_config_map_aws_auth" {
  value = local.config_map_aws_auth
  sensitive = true
}
output "eks_config_map_aws_auth_apply" {
  value     = "terraform output config_map_aws_auth | kubectl apply -f -"
}
output "eks_kubeconfig" {
  value = local.kubeconfig
  sensitive = true
}
output "eks_kubeconfig_replace" {
  value     = "terraform output kubeconfig > ~/.kube/config"
}
output "eks_sdm_cli" {
  value     = local.sdm_add_cli
  sensitive = true
}
output "eks_add_to_sdm" {
  value     = "eval $(terraform output eks_sdm_cli)"
}