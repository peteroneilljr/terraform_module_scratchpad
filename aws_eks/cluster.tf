#################
# control plane
#################
# resource "aws_security_group" "eks_cluster" {
#   name        = "${var.cluster_name} access group"
#   vpc_id      = var.vpc_id

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = var.tags
# }

# EKS Control Plane security group
# resource "aws_security_group_rule" "eks_cluster" {

#   from_port                = 443
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.eks_cluster.id
#   source_security_group_id = aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
#   to_port                  = 443
#   type                     = "ingress"  
#   depends_on = [aws_eks_cluster.cluster]
# }
# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  enabled_cluster_log_types = []
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.cluster.arn
  version                   = var.eks_version  

  vpc_config {
    subnet_ids              = flatten([var.public_subnets, var.private_subnets])
    security_group_ids      = []
    endpoint_public_access  = "true"
  }  
  tags = var.tags  
  
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
    aws_cloudwatch_log_group.cluster
  ]
}
resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/eks-test/cluster"
  retention_in_days = 7
}
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
tags = var.tags
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}