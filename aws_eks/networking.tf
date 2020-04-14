
# ###############################################################################
# # VPC resources
# ###############################################################################
# #  * Subnets
# #  * Route Table

# data "aws_availability_zones" "available" {
#   state = "available"
# }
# resource "aws_subnet" "eks" {
#   count = length(data.aws_availability_zones.available.names)

#   availability_zone = data.aws_availability_zones.available.names[count.index]
#   cidr_block        = cidrsubnet(var.vpc_cidr, 8, "${count.index + var.eks_cidr_block}")
#   vpc_id = var.vpc_id

#   tags = merge(map(
#     "Name", "${var.eks_cluster_name}",
#     "kubernetes.io/cluster/${var.eks_cluster_name}", "shared",
#   ), var.default_tags)
# }

# resource "aws_route_table" "eks" {
#   vpc_id = var.vpc_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = var.vpc_igw
#   }
#   tags = var.default_tags
# }

# resource "aws_route_table_association" "eks" {
#   count = length(aws_subnet.eks)

#   subnet_id      = aws_subnet.eks.*.id[count.index]
#   route_table_id = aws_route_table.eks.id
# }
