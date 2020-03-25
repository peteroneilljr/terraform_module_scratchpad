# Amazon EKS module

~~~
module "eks" {
  source           = "./modules/aws_eks"
  eks_cluster_name = "peter-cluster"
  cluster_version  = "1.14"
  subnets          = aws_subnet.peter_private_subnet.*.id
  vpc_id           = aws_vpc.peter_vpc.id
  vpc_igw          = aws_internet_gateway.peter_vpc_igw.id
  vpc_cidr         = aws_vpc.peter_vpc.cidr_block
  eks_cidr_block   = "50" # Turns into 10.17.50.0/24

  default_tags = var.default_tags
}

output "eks_context" {
  value = module.eks.eks_kubeconfig
}

output "eks_auth" {
  value = module.eks.eks_config_map_aws_auth
}
~~~