# Zscaler "cc_ilb" deployment type

This deployment type is intended for production/brownfield purposes. Full set of resources provisioned listed below, but by default this will effectively create all network infrastructure dependencies for a GCP environment. Creates 1 new "Management" VPC with 1 CC-Mgmt subnet; 1 "Service" VPC with 1 CC-Service subnet; 1 Cloud Router + NAT Gateway per VPC; generates local key pair .pem file for ssh access to all VMs. All network infrastructure resource have conditional "byo" variables, that can be inputted if they already exist (like VPC, subnet, Cloud Router, and Cloud NAT).<br>

Additionally: Creates 1 Cloud Connector compute instance template + between [1-3] zonal managed instance groups to deploy Cloud Connector appliances with a dedicated service account associated for accessing Secret Manager. This template also leverages the terraform-zscc-ilb-gcp module to create the necessary backend service, forwarding rule, health check, and firewall rules needed to front all cloud connector instances for highly available/resilient workload traffic forwarding; and optionally the terraform-zscc-cloud-dns-gcp module to create Google Cloud DNS forward zones intended for ZPA App Segment DNS redirection.

## How to deploy:

### Option 1 (guided):
Optional - First edit examples/cc_ilb/terraform.tfvars with any "byo" variable values that already exist in your environment and save the file.
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec up
- enter "brownfield"
- enter "cc_ilb"
- follow the remainder of the authentication and configuration input prompts.
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm

### Option 2 (manual):
Modify/populate any required variable input values in examples/cc_ilb/terraform.tfvars file and save.

From cc_ilb directory execute:
- terraform init
- terraform apply

## How to destroy:

### Option 1 (guided):
From the examples directory, run the zsec bash script that walks to all required inputs.
- ./zsec destroy

### Option 2 (manual):
From cc_ilb directory execute:
- terraform destroy
