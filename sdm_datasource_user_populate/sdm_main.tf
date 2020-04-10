module "sdm_accounts" {
  source = "./modules/sdm_accounts"
  
  role_name = "tf_role"
  users = [
    {
      first_name = "dan"
      last_name  = "one"
      email      = "peter+one@strongdm.com"
      suspended  = false
    },
    {
      first_name = "andy"
      last_name  = "two"
      email      = "peter+two@strongdm.com"
      suspended  = false
    },
    {
      first_name = "david"
      last_name  = "three"
      email      = "peter+three@strongdm.com"
      suspended  = false
    }
  ]
}

module "sdm_datasoure_user_populate" {
  source = "./modules/sdm_datasource_user_populate"
  name          = "tf-ubuntu-user-populate"
  username      = "ubuntu"
  hostname      = "ec2-54-71-248-28.us-west-2.compute.amazonaws.com"
  port          = 22

  users_first_name = module.sdm_accounts.users_first_name
  users_last_name = module.sdm_accounts.users_last_name
}
output "sdm_datasource_pubkey" {
  value = module.sdm_datasoure_user_populate.pubkeys
}

locals {
  playbooks_path = abspath("./playbooks/")
}

resource "local_file" "linix_users" {
    content     =  templatefile("${local.playbooks_path}/create_users_template.yml", {
      range = length(module.sdm_accounts.users_first_name), 
      first_names = module.sdm_accounts.users_first_name,
      last_names = module.sdm_accounts.users_last_name,
      ssh_keys = module.sdm_datasoure_user_populate.pubkeys
    })
    filename = "${local.playbooks_path}/create_users.yml"
}

resource "null_resource" "linix_users" {
  triggers = {
    linix_users = sha1(local_file.linix_users.content)
  }
  provisioner "local-exec" {
    command = "ansible-playbook ${local_file.linix_users.filename} -i ${local.playbooks_path}/hosts"
  }
}
