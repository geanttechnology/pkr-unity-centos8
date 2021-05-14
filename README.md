<div align="center">
  <img width="128" src="./logo.svg" alt="errors logo" />
  <h1>Imperva Unity CentOS 8 Image</h1>
  <p>Packer template for creating the customize CentOS 8 image for Imperva Unity</p>
  <hr />
  <br />
  <a href="#">
    <img src="https://img.shields.io/badge/stability-alpha-ff69b4?style=for-the-badge" />
  </a>
  <a href="https://en.wikipedia.org/wiki/MIT_License" target="_blank">
    <img src="https://img.shields.io/badge/license-MIT-maroon?style=for-the-badge" />
  </a>
  <a href="#">
    <img src="https://img.shields.io/badge/support-community-purple?style=for-the-badge" />
  </a>
  <a href="https://conventionalcommits.org" target="_blank">
    <img src="https://img.shields.io/badge/Conventional%20Commits-1.0.0-orange.svg?style=for-the-badge" />
  </a>
</div>
<br />
<hr />
<br />

<!-- omit in toc -->
## Table of Contents
- [👁️ Overview](#️-overview)
- [✅ Requirements](#-requirements)
- [✴️ Features](#️-features)
  - [Amazon Web Services AMI](#amazon-web-services-ami)
- [☑️ Build Requirements](#️-build-requirements)
  - [Amazon Web Services](#amazon-web-services)
- [⛏️ Build Process](#️-build-process)
- [➡️ Inputs](#️-inputs)
- [📃 License](#-license)
- [❓ Questions, Issues and Feature Requests](#-questions-issues-and-feature-requests)

## 👁️ Overview

This repository contains the Packer template(s) for building the CentOS 8 server image for the demos available in the Imperva Unity platform.

## ✅ Requirements

* This template requires Packer v1.7 or later.
* This OS template is supported for the following platforms:
  * Amazon Web Services
  
## ✴️ Features

This image is a standard build of CentOS 8 with several features built into it:

- The following packages are installed:
  - epel-release
  - firewalld
  - jq
  - nvme-cli
  - python3
  - python3-pip
  - python3-dnf-plugin-versionlock
  - traceroute
  - unzip
- The following PIP packages are installed:
  - boto3
  - docker-compose
  - pyOpenSSL
  - yq
- Docker is enabled by default
- The default prompt has been changed and colorized to provide additional information
- The default username has been changed to `imperva`
- Network interface names use predictable legacy naming such as `eth0`
- SSH is configured to listen on port `8222`
- SSH agent information is preserved when using the `sudo` command
- The Smallstep [step-ca](https://smallstep.com/docs/step-ca) and [step](https://smallstep.com/docs/step-cli) commands are installed

### Amazon Web Services AMI

The AWS machine image has a few additional features which include:

- The AWS CLI v2 is installed
- The AWS SSM agent is installed
- `nvme` drives have aliases mapped to standard `/dev/sdX` device names
- Instance metadata is retrieved using the AWS instance metadata service version 2
- The following AWS instance-related variables are set for BASH shells:

  | Environment Variable | Description |
  |----------------------|-------------|
  | `VM_CLOUD_ID` | Always set to `ec2` |
  | `VM_INSTANCE_ID` | The AWS instance ID |
  | `VM_PUBLIC_IP` | If set, the public IP address associated with the instance; otherwise empty |
  | `VM_PRIVATE_IP` | The private IP address for the primary (eth0) interface |
  | `VM_VPC_ID` | The ID of the VPC to which the instance belongs |
  | `VM_SUBNET_ID` | The ID of the subnet within the VPC to which the primary (eth0) interface is attached |
  | `VM_ZONE` | The AWS availability zone in which the instance is deployed |
  | `VM_REGION` | The AWS region in which the instance is deployed |
  | `VM_NAME` | The value of the `iac.impervaunity.io/name` tag, if set |
  | `VM_HOSTNAME` | The value of the `iac.impervaunity.io/hostname` tag, if set; defaults to the output of the `hostname -s` command |
  | `VM_DNS_SUFFIX` | The value of the `iac.impervaunity.io/dns-suffix` tag, if set; defaults to the output of the `hostname -d` command |
  | `VM_FQDN` | The fully qualified domain name of the host created by joining `VM_HOSTNAME` and `VM_DNS_SUFFIX` with a period (.); if `VM_DNS_SUFFIX` is not set or empty, it will simply be the value of `VM_HOSTNAME` |
  | `VM_RESOURCE_GROUP` | The value of the `iac.impervaunity.io/resource-group` tag, if set |
  | `VM_VPC_NAME` | The value of the VPC's `iac.impervaunity.io/name` tag, if set |


## ☑️ Build Requirements

- [HashiCorp Packer 1.7 or later](https://www.packer.io/downloads) must be installed on your machine.
- When building on Windows, you must install and run the build from the Windows Subsystem for Linux (see <https://docs.microsoft.com/en-us/windows/wsl/install-win10>).
- `bash` and `tar` must be installed on all operating systems.

### Amazon Web Services

- The [AWS CLI](https://aws.amazon.com/cli) must be installed on your machine.
- The [AWS Session Manager client](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html) must be installed on your machine.
- You must run the `aws configure` command to configure the connection to your AWS account.
- If you do not use the default profile for the AWS client, be sure to set the `AWS_PROFILE` environment variable to the name of the profile that should be used.
- Verify that the user/role authenticating to the AWS account has the appropriate permissions to be able to complete the build. (see **IAM Task or Instance Role** on <https://www.packer.io/docs/builders/amazon>).
- You **must** have a VPC deployed using the [Terraform AWS Unity VPC](https://github.com/imperva-marketing/tf-unity-aws-vpc) module.

## ⛏️ Build Process

To build the image simply run `packer build` supplying the appropriate `.pkr.hcl` file for your cloud platform.

For example, to build the image for Amazon EC2, simply run:

`packer build aws-ec2.pkr.hcl`

You can either choose to supply values to variables when prompted or supply values automatically through the use of command-line flags, variable definitions files or environment variables. (see <https://www.packer.io/docs/templates/hcl_templates/variables>)

Consult the [Inputs](#inputs) section below for information on available input variables.

## ➡️ Inputs

Variables with `(none)` as the default must be specified when building this image.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `base_name` | `string` | `imperva-unity-centos8` | The base name of the AMI to create your AWS account. A version and build number are automatically appended to this name. |
| `extra_accounts` | `list(string)` | `[]` | List AWS account IDs to share the AMI with. |
| `extra_regions` | `list(string)` | `[]` | List of additional regions to copy the resulting AMI to. |
| `extra_image_tags` | `map(string)` | `{}` | Extra EC2 tags to add to the resulting AMI. |
| `region` | `string` | (none) | The region in which to build and upload the AMI. You **must** have a VPC deployed by the [Terraform AWS Unity VPC](https://github.com/imperva-marketing/tf-unity-aws-vpc) module in this region. | 
| `vpc_name` | `string` | (none) | The name of the VPC you supplied when deploying the [Terraform AWS Unity VPC](https://github.com/imperva-marketing/tf-unity-aws-vpc) module. |

## 📃 License

This module is distributed under the MIT License.

## ❓ Questions, Issues and Feature Requests

_This project is not supported through the official Imperva Support channels. It is supported through the Imperva Technical Marketing Team on a best-effort basis. There are no warranties, SLAs or guarantees on support for this project._

If you have questions about this project, find a bug or wish to submit a feature request, please [submit an issue](https://github.com/imperva-marketing/pkr-unity-centos8/issues).
