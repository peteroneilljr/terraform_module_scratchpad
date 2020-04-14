# Amazon EKS module

## sample
~~~
# module "eks" {
#   source           = "./modules/aws_eks"
#   eks_cluster_name = "peter-k8s"
#   cluster_version  = "1.15"
#   vpc_id           = module.vpc.vpc_id
#   vpc_igw          = module.vpc.igw_id
#   vpc_cidr         = module.vpc.vpc_cidr_block # Supply a /16 cidr block
#   eks_cidr_block   = "50" # Assigns subnets x.x.50.x/24

#   default_tags = var.default_tags
# }

# output "eks_kubeconfig" {
#   value = module.eks.kubeconfig
#   sensitive = true
# }

~~~