<a href="https://terraform.io">
    <img src="https://raw.githubusercontent.com/hashicorp/terraform-website/master/public/img/logo-text.svg" alt="Terraform logo" title="Terraform" height="50" width="250" />
</a>
<a href="https://www.zscaler.com/">
    <img src="https://www.zscaler.com/themes/custom/zscaler/logo.svg" alt="Zscaler logo" title="Zscaler" height="50" width="250" />
</a>

Zscaler Cloud Connector GCP Terraform Modules
===========================================================================================================

# **README for GCP Terraform**
This README serves as a quick start guide to deploy Zscaler Cloud Connector resources in an GCP cloud using Terraform. To learn more about
the resources created when deploying Cloud Connector with Terraform, see [Deployment Templates for Zscaler Cloud Connector](https://help.zscaler.com/cloud-connector/about-cloud-automation-scripts).

## **GCP Deployment Scripts for Terraform**

Use this repository to create the deployment resources required to deploy and operate Cloud Connector in a new or existing virtual private
cloud (VPC). The [examples](examples/) directory contains complete automation scripts for both greenfield/POV and brownfield/production use.

## **Prerequisites**

The GCP Terraform scripts leverage Terraform v1.1.9 which includes full binary and provider support for macOS M1 chips, but any Terraform
version 0.13.7 should be generally supported.

-   provider registry.terraform.io/hashicorp/google v4.70.x
-   provider registry.terraform.io/hashicorp/random v3.3.x
-   provider registry.terraform.io/hashicorp/local v2.2.x
-   provider registry.terraform.io/hashicorp/null v3.1.x
-   provider registry.terraform.io/providers/hashicorp/tls v3.4.x

### **GCP requirements**
1.  A valid GCP Administrator account to create a terraform service account with access to deploy required resources
2.  GCP service account json keyfile copied to examples/{deployment type}/credentials/
3.  GCP Region (E.g. us-central1)
4.  Subscribe and accept the terms of using Zscaler Cloud Connector image at [this link](https://TBD)

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

## **Test/Greenfield Deployments** 

Use this if you are building an entire cluster from the ground up. These templates include a bastion host and test workloads and are designed for greenfield/POV testing. 

###  **Starter Deployment Template**

Use the [**Starter Deployment Template**](examples/base_1cc/) to deploy your Cloud Connector in a new VPC.

### **Starter Deployment Template with ZPA**

Use the [**Starter Deployment Template with ZPA**](examples/base_1cc_zpa) to deploy your Cloud Connector in a new VPC with ZPA DNS zone forward resolver capability.

### **Starter Deployment Template with Internal Load Balancer (ILB)**

Use the [**Starter Deployment Template with ILB**](examples/base_cc_ilb) to deploy your Cloud Connector in a new VPC and to load balance traffic across multiple Cloud Connectors. Zscaler\'s recommended deployment method is Internal Load Balancer (ILB). ILB distributes traffic across multiple Cloud Connectors and achieves high availability.

### **Starter Deployment Template with Internal Load Balancer (ILB) and ZPA**

Use the [**Starter Deployment Template with ILB and ZPA**](examples/base_cc_ilb_zpa) to deploy your Cloud Connector in a new VPC and to load balance traffic across multiple Cloud Connectors. Zscaler\'s recommended deployment method is Internal Load Balancer (ILB). ILB distributes traffic across multiple Cloud Connectors and achieves high availability. Also includes ZPA DNS zone forward resolver capability.

## **Prod/Brownfield Deployments**

Brownfield deployment templates are most applicable for production deployments and have more customization options than a \"base\"
deployment. They also do not include a bastion or workload hosts deployed. See [Modules](https://github.com/zscaler/terraform-gcp-cloud-connector-modules/tree/main/examples) for the Terraform configurations for brownfield deployment.

### **Custom Deployment Template with Internal Load Balancer (ILB)**

Use the [**Custom Deployment template with ILB**](examples/cc_ilb) to deploy your Cloud Connector in new or existing VPCs and load balance traffic across multiple Cloud Connectors. Zscaler\'s recommended deployment method is Internal Load Balancer (ILB). ILB distributes traffic across multiple Cloud Connectors and achieves high availability. Optionally includes ZPA DNS zone forward resolver capability.
