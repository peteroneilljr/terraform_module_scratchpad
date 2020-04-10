
resource "sdm_resource" "this" {
  count = length(var.users_first_name)
  ssh {
    name          = "${var.name}_${var.users_first_name[count.index]}_${var.users_last_name[count.index]}"
    username      = "${var.users_first_name[count.index]}_${var.users_last_name[count.index]}"
    hostname      = var.hostname
    port          = var.port
  }
}

# locals {

# %{ for name in var.user_list }
# server ${ip}
# %{ endfor }
#   usernames
# }

# resource "null_resource" "user_names" {
#   count = length(var.user_list)
#   name = "${var.user_list[count.index]["first_name"]}_${var.user_list[count.index]["last_name"]}"
# }

output "pubkeys" {
  value = sdm_resource.this.*.ssh.0.public_key
}
