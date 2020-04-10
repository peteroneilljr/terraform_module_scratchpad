resource "sdm_account" "this" {
  count = length(var.users)
  
  user {
    first_name = var.users[count.index]["first_name"]
    last_name  = var.users[count.index]["last_name"]
    email      = var.users[count.index]["email"]
    suspended  = var.users[count.index]["suspended"]
  }
}

resource "sdm_account_attachment" "this" {
  count = length(var.users)

  account_id = sdm_account.this[count.index].id
  role_id = sdm_role.this.id
}

resource "sdm_role" "this" {
  name = var.role_name
}
