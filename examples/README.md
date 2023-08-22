# Zscaler Cloud Connector Cluster Infrastructure Setup

**Terraform configurations and modules for deploying Zscaler Cloud Connector Cluster in GCP.**

## Prerequisites (You will be prompted for GCP keys and region during deployment)

### GCP requirements
1.  A valid GCP Administrator account to create a terraform service account with access to deploy required resources
2.  GCP service account json keyfile copied to examples/{deployment type}/credentials/
3.  GCP Region (E.g. us-central1)
4.  During Limited Availability, private image access can be granted to Zscaler customers by reaching to your account/support team

### Zscaler requirements
5.  A valid Zscaler Cloud Connector provisioning URL generated from the Cloud Connector Portal
6.  Zscaler Cloud Connector Credentials (api key, username, password) are stored in GCP Secrets Manager

### **Terraform client requirements**
7. If executing Terraform via the "zsec" wrapper bash script, it is advised that you run from a MacOS or Linux workstation. Minimum installed application requirements to successfully from the script are:
- bash
- curl
- unzip
<br>
<br>

See: [Zscaler Cloud Connector GCP Deployment Guide](https://TBD) for additional prerequisite provisioning steps.

## Deploying the cluster
(The automated tool can run only from MacOS and Linux. You can also upload all repo contents to the respective public cloud provider Cloud Shells and run directly from there).   
 
**1. Test/Greenfield Deployments**

(Use this if you are building an entire cluster from ground up.
 Particularly useful for a Customer Demo/PoC or dev-test environment)

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: base_1cc) to setup your Cloud Connector (Details are documented inside the file)
- ./zsec up
- enter "greenfield"
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Test/Greenfield Deployment Types:**

```
Deployment Type: (base_1cc | base_1cc_zpa | base_cc_ilb | base_cc_ilb_zpa):
base_1cc: Creates 1 new "Management" VPC with 1 CC-Mgmt subnet and 1 bastion subnet; 1 "Service" VPC with 1 CC-Service subnet and 1 workload subnet; 1 Cloud Router + NAT Gateway per VPC; 1 Ubuntu client workload with a tagged default route next-hop to Cloud Connector service network instance; 1 Bastion Host assigned a dynamic public IP; generates local key pair .pem file for ssh access to all VMs; 1 Cloud Connector compute instance template + zonal managed instance group to deploy a single Cloud Connector appliance with a dedicated service account associated for accessing Secret Manager; tagged route table pointing workload default route next-hop to the CC Instance.
base_1cc_zpa: Everything from base_1cc + creates Google Cloud DNS forward zones intended for ZPA App Segment DNS redirection.
base_cc_ilb: Everything from base_1cc + option to deploy multiple Cloud Connectors across multiple zonal managed instance groups behind an Internal Load Balancer (ILB) including new: backend service, forwarding rule, health check, and firewall rules needed to front all cloud connector instances for highly available/resilient workload traffic forwarding; tagged route table pointing workload default route next-hop to the ILB front end IP.
base_cc_ilb_zpa: Everything from base_cc_ilb + creates Google Cloud DNS forward zones intended for ZPA App Segment DNS redirection.
```

**2. Prod/Brownfield Deployments**

(These templates would be most applicable for production deployments and have more customization options than a "base" deployments). They also do not include a bastion or workload hosts deployed.

```
bash
cd examples
Optional: Edit the terraform.tfvars file under your desired deployment type (ie: cc_ilb) to setup your Cloud Connector (Details are documented inside the file)
- ./zsec up
- enter "brownfield"
- enter <desired deployment type>
- follow prompts for any additional configuration inputs. *keep in mind, any modifications done to terraform.tfvars first will override any inputs from the zsec script*
- script will detect client operating system and download/run a specific version of terraform in a temporary bin directory
- inputs will be validated and terraform init/apply will automatically exectute.
- verify all resources that will be created/modified and enter "yes" to confirm
```

**Prod/Brownfield Deployment Types**

```
Deployment Type: (cc_ilb):
cc_ilb: Creates 1 new "Management" VPC with 1 CC-Mgmt subnet; 1 "Service" VPC with 1 CC-Service subnet; 1 Cloud Router + NAT Gateway per VPC; generates local key pair .pem file for ssh access to all VMs. All network infrastructure resource have conditional "byo" variables, that can be inputted if they already exist (like VPC, subnet, Cloud Router, and Cloud NAT); creates 1 Cloud Connector compute instance template with option to deploy multiple Cloud Connectors across multiple zonal managed instance groups behind an Internal Load Balancer (ILB) including new: backend service, forwarding rule, health check, and firewall rules needed to front all cloud connector instances for highly available/resilient workload traffic forwarding; and optional capability to create Google Cloud DNS forward zones intended for ZPA App Segment DNS redirection.
```

## Destroying the cluster
```
cd examples
- ./zsec destroy
- verify all resources that will be destroyed and enter "yes" to confirm
```

## Notes
```
1. For auto approval set environment variable **AUTO_APPROVE** or add `export AUTO_APPROVE=1`
2. For deployment type set environment variable **dtype** to the required deployment type or add `export dtype=base_cc_ilb`
3. To provide new credentials or region, delete the autogenerated .zsecrc file in your current working directory and re-run zsec.
```
