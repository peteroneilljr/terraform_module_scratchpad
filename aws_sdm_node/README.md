# Create strongDM Gateawys and Relays

This that might be cool to have
- bool for ssh access
  - Creates key only when needed
- specify placement by subnet
- lifecycle ignore ami updating 
- bool for cloudwatch alarms
- bool for IP or DNS
- detailed monitoring
- ~~create before destroy?~~
- egress port
- egress SG
- high-availability
- store token in parameter store 

~~~
module "sdm" {
  source              = "./modules/aws_sdm_node"

  vpc_id              = aws_vpc.peter_vpc.id
  gateway_listen_port = 5000

  gateway_subnets = []
  relay_subnets = []
  
  ssh_access = true
  cloudwatch_metrics = false

}
~~~