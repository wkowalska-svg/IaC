output "vpc_self_link" { value = module.network.vpc_self_link }
output "subnets" { value = module.network.subnet_self_links }
output "vm_ip" { value = module.vm.external_ip }