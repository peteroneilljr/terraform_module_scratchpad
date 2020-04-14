#################
# Worker Nodes
#################
resource "aws_eks_node_group" "private_managed_workers" {  
  count = length(var.private_subnets) > 0 ? 1:0
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${aws_eks_cluster.cluster.name}-private-managed-workers"
  node_role_arn   = aws_iam_role.managed_workers.arn
  subnet_ids      = var.private_subnets 
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }  
  instance_types = ["t3.small"]  

  # remote_access {
  #   ec2_ssh_key               = null #var.ssh_key_name
  #   source_security_group_ids = null #[module.bastion.security_group_id]
  # }  
  # release_version = var.managed_node_group_release_version  
  tags = var.tags  
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]  
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_eks_node_group" "public_managed_workers" {  
  count = length(var.public_subnets) > 0 ? 1:0
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "${aws_eks_cluster.cluster.name}-public-managed-workers"
  node_role_arn   = aws_iam_role.managed_workers.arn
  subnet_ids      = var.public_subnets 
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }  
  instance_types = ["t3.small"]  

  # remote_access {
  #   ec2_ssh_key               = null #var.ssh_key_name
  #   source_security_group_ids = null #[module.bastion.security_group_id]
  # }  
  # release_version = var.managed_node_group_release_version  
  tags = var.tags  
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-AmazonEC2ContainerRegistryReadOnly,
  ]  
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_iam_role" "managed_workers" {  
  name = "${aws_eks_cluster.cluster.name}-managed-node-group-role"  
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "eks-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.managed_workers.name
}
resource "aws_iam_role_policy_attachment" "eks-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.managed_workers.name
}
resource "aws_iam_role_policy_attachment" "eks-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.managed_workers.name
}