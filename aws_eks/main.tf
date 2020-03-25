# Sourced from
# https://aws.amazon.com/blogs/startups/from-zero-to-eks-with-terraform-and-helm/


###############################################################################
# VPC resources
###############################################################################
#  * Subnets
#  * Route Table

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "eks" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, "${count.index + var.eks_cidr_block}")
  # cidr_block        = "10.17.${count.index + 50}.0/24"
  vpc_id            = var.vpc_id

  tags = merge(map(
    "Name", "${var.eks_cluster_name}",
    "kubernetes.io/cluster/${var.eks_cluster_name}", "shared",
  ), var.default_tags)
}

resource "aws_route_table" "eks" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_igw
  }
  tags = var.default_tags
}

resource "aws_route_table_association" "eks" {
  count = length(aws_subnet.eks)

  subnet_id      = aws_subnet.eks.*.id[count.index]
  route_table_id = aws_route_table.eks.id
}


###############################################################################
# EKS Cluster Resources
###############################################################################


#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "eks-cluster" {
  name = "${var.eks_cluster_name}-cluster-role"

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
  tags = var.default_tags

}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_security_group" "eks" {
  name        = "${var.eks_cluster_name}-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.eks_cluster_name}-sg"
  }, var.default_tags)
}

resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.eks.id]
    subnet_ids         = aws_subnet.eks[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSServicePolicy,
  ]
  tags = var.default_tags

}

###############################################################################
# EKS Worker Nodes Resources
###############################################################################

#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "eks-node" {
  name = "${var.eks_cluster_name}-node-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
  tags = var.default_tags

}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-node.name
}

resource "aws_iam_role_policy_attachment" "eks-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-node.name
}

resource "aws_eks_node_group" "eks" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.eks_cluster_name
  node_role_arn   = aws_iam_role.eks-node.arn
  subnet_ids      = aws_subnet.eks[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

# ###############################################################################
# # Workstation External IP
# ###############################################################################

# # This configuration is not required and is
# # only provided as an example to easily fetch
# # the external IP of your local workstation to
# # configure inbound EC2 Security Group access
# # to the Kubernetes cluster.
# #

# data "http" "workstation-external-ip" {
#   url = "http://ipv4.icanhazip.com"
# }

# # Override with variable or hardcoded value if necessary
# locals {
#   workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
# }

# # could add a list of IP's to whitelist and have this be dynamic repeating block.
# resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
#   cidr_blocks       = [local.workstation-external-cidr]
#   description       = "Allow workstation to communicate with the cluster API Server"
#   from_port         = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.eks.id
#   to_port           = 443
#   type              = "ingress"
# }
