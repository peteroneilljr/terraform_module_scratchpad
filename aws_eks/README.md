# Amazon EKS module

~~~
module "eks" {
  source          = "./modules/aws_eks"
  eks_cluster_name    = "peter-cluster"
  cluster_version = "1.14"
  subnets         = aws_subnet.peter_private_subnet.*.id
  vpc_id          = aws_vpc.peter_vpc.id
  vpc_igw         = aws_internet_gateway.peter_vpc_igw.id
  eks_cidr_block = "10.17.$${count.index + 50}.0/24"

  default_tags = var.default_tags
}

output "eks_context" {
  value = module.eks.eks_kubeconfig
}

output "eks_auth" {
  value = module.eks.eks_config_map_aws_auth
}
~~~