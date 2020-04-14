
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

  vpc_id = var.vpc_id
  
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, "${count.index + var.eks_cidr_block}")

  tags = merge(map(
    "Name", "${var.cluster_name}",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
  ), var.tags)

}

resource "aws_route_table" "eks" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.vpc_igw
  }
  tags = var.tags
}

resource "aws_route_table_association" "eks" {
  count = length(aws_subnet.eks)

  subnet_id      = aws_subnet.eks.*.id[count.index]
  route_table_id = aws_route_table.eks.id
}
