
variable "mongoDB_org_id" {
  # strongDM test org
  default = "599eed229f78f769464d1b4f"
}

# stress test 
# - https://github.com/mongodb/mongo-perf
# MongoDB Atlas failover tests 
# - https://docs.atlas.mongodb.com/tutorial/test-failover/index.html#test-failover-process


resource "mongodbatlas_project" "mongo" {
  name   = var.mongo_name
  org_id = var.mongoDB_org_id
}

resource "mongodbatlas_project_ip_whitelist" "mongo" {
  project_id = mongodbatlas_project.mongo.id

  whitelist {
    cidr_block = local.workstation-external-cidr
    comment    = "terraform machine"
  }
  whitelist {
    ip_address = var.sdm_gateway_ip
    # Can't think of a way to grab the IP from the autoscaling group
    comment = "SDM Gateway"
  }
  whitelist {
    ip_address = "34.221.143.229"
    comment    = "House of jorg"
  }
}

resource "mongodbatlas_cluster" "mongo" {
  project_id = mongodbatlas_project.mongo.id
  name       = var.mongo_name
  num_shards = 1

  replication_factor           = 3
  backup_enabled               = false
  auto_scaling_disk_gb_enabled = true
  mongo_db_major_version       = "4.2"

  //Provider Settings "block"
  provider_name               = var.provider_name
  disk_size_gb                = 50
  provider_disk_iops          = 150
  provider_volume_type        = "STANDARD"
  provider_instance_size_name = "M30"
  provider_region_name        = var.provider_name == "GCP" ? "CENTRAL_US" : "US_WEST_2"
}

resource "null_resource" "mongo" {
  count = var.sdm_admin_token != "" ? 1 : 0
  triggers = {
    cluster_instance_ids = mongodbatlas_cluster.mongo.mongo_uri
  }

  provisioner "local-exec" {
    command = local.sdm_add_mongo
  }
}

resource "mongodbatlas_database_user" "mongo" {
  username = var.mongo_username
  password = var.mongo_password
  project_id    = mongodbatlas_project.mongo.id
  database_name = "admin"
  roles {
    role_name     = "atlasAdmin"
    database_name = "admin"
  }
}


data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}


locals {
  sdm_add_mongo = <<SDMMONGO
/SDM_ADMIN_TOKEN="${var.sdm_admin_token}"; \
/usr/local/bin/sdm admin datasources delete ${mongodbatlas_cluster.mongo.name} || \
echo "Datasource ${mongodbatlas_cluster.mongo.name} not found"; \
/usr/local/bin/sdm admin datasources add mongo-replicaset \
--auth-database ${mongodbatlas_database_user.mongo.database_name} \
--hostname ${replace(mongodbatlas_cluster.mongo.mongo_uri, "mongodb://", "")} \
--replica-set ${mongodbatlas_cluster.mongo.name}-shard-00 \
--username ${mongodbatlas_database_user.mongo.username} \
--password ${mongodbatlas_database_user.mongo.password} \
--tls-required \
--tags 'creator=peter,managedBy=terraform' \
${mongodbatlas_cluster.mongo.name} && \
echo "added 1 datasource ${mongodbatlas_cluster.mongo.name}" && \
/usr/local/bin/sdm admin roles grant ${mongodbatlas_cluster.mongo.name} NOC
SDMMONGO
}

# output "sdm_add_mongo" {
#   value = local.sdm_add_mongo
#   sensitive = true
# }
# output "sdm_add_mongo_eval" {
#   value = "terraform output sdm_add_mongo | /bin/bash -"
# }

output "cluster_name" {
  value = mongodbatlas_cluster.mongo.name
}
