# output "sdm_gateways" {
#   value = {
#     for instance in aws_instance.sdm_gateway :
#     instance.tags.Name => instance.public_ip
#   }
# }