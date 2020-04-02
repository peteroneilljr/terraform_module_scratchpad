# Create strongDM Gateawys and Relays

Things that might be cool to have
- conditional create module
- ~~bool for cloudwatch alarms~~
- ~~add CMK to parameter store~~
- ~~bool for ssh access~~
- ~~specify placement by subnet~~
- ~~lifecycle ignore ami updating~~
- ~~detailed monitoring~~
- ~~bool for IP or DNS~~
- ~~only use EIP for gateways~~
- ~~create before destroy?~~
- ~~egress only SG for relay~~
- ~~gateway count~~
- ~~store token in parameter store~~
- ~~dev mode, smaller instance size~~

Documentation
- Descriptions for all variables
- Required AWS permissions for each option
- README with examples
- Full Examples in folders
- Test suite? 


~~~
module "sdm" {
  source = "./modules/aws_sdm_node"

  sdm_node_name = "dev-env"
  deploy_vpc_id = module.vpc.vpc_id

  gateway_listen_port  = 5000
  deploy_gw_subnet_ids = [module.vpc.public_subnets[1]]

  deploy_relay_subnet_ids = [module.vpc.private_subnets[1]]

  ssh_access = true
  ssh_key    = aws_key_pair.sdm_key.key_name
  ssh_source = "0.0.0.0/0"

  # cloudwatch_metrics = false

  dev_mode = true
  tags     = var.default_tags
}
~~~