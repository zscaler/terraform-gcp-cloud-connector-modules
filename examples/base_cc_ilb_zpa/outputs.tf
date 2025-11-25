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

Login Instructions & Resource Attributes
SSH to CLOUD CONNECTOR
%{for k, v in local.cc_map~}
ssh -F ssh_config ccvm-${k}
%{endfor~}  

All Cloud Connector Management IPs:
%{for k, v in local.cc_map~}
ccvm-${k} = ${v}
%{endfor~}

All Cloud Connector Service IPs:
${join("\n", module.cc_vm.cc_forwarding_ip)}


WORKLOAD Details/Commands:
SSH to WORKLOAD
%{for k, v in local.workload_map~}
ssh -F ssh_config workload-${k}
%{endfor~}  

WORKLOAD IPs:
%{for k, v in local.workload_map~}
workload-${k} = ${v}
%{endfor~}  


BASTION Jump Host Details/Commands:
1) Copy the SSH key to BASTION home directory
scp -F ssh_config ${var.name_prefix}-key-${random_string.suffix.result}.pem ubuntu@${module.bastion.public_ip}:/home/ubuntu/.

2) SSH to BASTION
ssh -F ssh_config bastion

BASTION Public IP: 
${module.bastion.public_ip}


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

Instance Group Names:
${join("\n", module.cc_vm.instance_group_names)}

Internal Load Balancer IP:
${module.ilb.next_hop_ilb_ip_address}

TB
}

locals {
  workload_map = {
    for index, ip in module.workload.private_ip :
    index => ip
  }
  cc_map = {
    for index, ip in module.cc_vm.cc_management_ip :
    index => ip
  }
  ssh_config_contents = <<SSH_CONFIG
    Host bastion
      HostName ${module.bastion.public_ip}
      User ubuntu
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem

    %{for k, v in local.workload_map~}
Host workload-${k}
      HostName ${v}
      User ubuntu
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem
      StrictHostKeyChecking no
      ProxyJump bastion
      ProxyCommand ssh bastion -W %h:%p
    %{endfor~}    
    
    %{for k, v in local.cc_map~}
Host ccvm-${k}
      HostName ${v}
      User zsroot
      IdentityFile ${var.name_prefix}-key-${random_string.suffix.result}.pem
      StrictHostKeyChecking no
      ProxyJump bastion        
      ProxyCommand ssh bastion -W %h:%p
    %{endfor~}
  SSH_CONFIG
}


output "testbedconfig" {
  description = "Google Cloud Testbed results"
  value       = local.testbedconfig
}

resource "local_file" "ssh_config" {
  content  = local.ssh_config_contents
  filename = "../ssh_config"
}

resource "local_file" "testbed" {
  content  = local.testbedconfig
  filename = "../testbed.txt"
}
