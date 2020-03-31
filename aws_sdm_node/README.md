# Create strongDM Gateawys and Relays

This that might be cool to have
- ~~bool for ssh access~~
- ~~specify placement by subnet~~
- ~~lifecycle ignore ami updating~~
- bool for cloudwatch alarms
- bool for IP or DNS
- only use EIP for gateways
- detailed monitoring
- ~~create before destroy?~~
- egress port
- egress SG
- gateway count
- store token in parameter store 
  encrypt token
- conditional create
- dev mode, smaller instance size

~~~
module "sdm" {
  source              = "./modules/aws_sdm_node"

  sdm_gateway_name = aws_support
  deploy_vpc_id              = aws_vpc.peter_vpc.id
  gateway_listen_port = 5000

  deploy_subnet_id = aws_subnet.peter_public_subnet[0].id
  
  ssh_access = true
  ssh_key = aws_key_pair.sdm_key.key_name
  ssh_source = "0.0.0.0/0"

  # cloudwatch_metrics = false

  tags = var.default_tags

}
~~~