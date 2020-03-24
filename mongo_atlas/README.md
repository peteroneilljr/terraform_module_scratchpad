# deploy mongo cluster

### Example GCP
~~~
module "mongo" {
  source = "./modules/mongo_atlas"
  sdm_gateway_ip = "40.83.169.180"
  mongo_name = "peter"
  # mongo_username = "username"
  # mongo_password = "password"
  sdm_admin_token = var.sdm_admin_full
  provider_name = "AWS"
  
}
output "mongo_cluster" {
  value = module.mongo.cluster_name
}
~~~