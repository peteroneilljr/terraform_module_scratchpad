output "subnet_ids" {
  value = aws_subnet.eks.*.id
}
output "cluster_name" {
  value = var.cluster_name
}
output "vpc_id" {
  value = var.vpc_id
}
