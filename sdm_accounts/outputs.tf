output "users_first_name" {
  value = flatten(sdm_account.this.*.user.0.first_name)
}
output "users_last_name" {
  value = flatten(sdm_account.this.*.user.0.last_name)
}