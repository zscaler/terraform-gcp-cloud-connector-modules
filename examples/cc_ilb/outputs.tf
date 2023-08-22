locals {
  testbedconfig = <<TB
***Disclaimer***
By default, these templates store two critical files to the "examples" directory. DO NOT delete/lose these files:
1. Terraform State file (terraform.tfstate) - Terraform must store state about your managed infrastructure and configuration. 
   This state is used by Terraform to map real world resources to your configuration, keep track of metadata, and to improve performance for large infrastructures.
   Terraform uses state to determine which changes to make to your infrastructure. 
   Prior to any operation, Terraform does a refresh to update the state with the real infrastructure.
   If this file is missing, you will NOT be able to make incremental changes to the environment resources without first importing state back to terraform manually.
2. SSH Private Key (.pem) file - Zscaler templates will attempt to create a new local private/public key pair for VM access (if a pre-existing one is not specified). 
   You (and subsequently Zscaler) will NOT be able to remotely access these VMs once deployed without valid SSH access.
***Disclaimer***


Project Name:
${module.cc_vm.instance_template_project}

Region:
${module.cc_vm.instance_template_region}

Forwarding/Service VPC Network:
${module.cc_vm.instance_template_forwarding_vpc}

Management VPC Network:
${module.cc_vm.instance_template_management_vpc}

Availability Zones:
${join("\n", module.cc_vm.instance_group_zones)}

All Cloud Connector Instance Primary Mgmt IPs:
${join("\n", module.cc_vm.cc_management_ip)}

All Cloud Connector Instance Primary Forwarding IPs:
${join("\n", module.cc_vm.cc_forwarding_ip)}

Internal Load Balancer IP:
${module.ilb.next_hop_ilb_ip_address}


TB
}

output "testbedconfig" {
  description = "Google Cloud Testbed results"
  value       = local.testbedconfig
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}
