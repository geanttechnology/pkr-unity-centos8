variable "base_name" {
  type        = string
  description = "The base name of the AMI to create your AWS account. A version and build number are automatically appended to this name."
  default     = "imperva-unity-centos8"
}

variable "extra_accounts" {
  type        = list(string)
  description = "List AWS account IDs to share the AMI with."
  default     = []
}

variable "extra_regions" {
  type        = list(string)
  description = "List of additional regions to copy the resulting AMI to."
  default     = []
}

variable "extra_image_tags" {
  type        = map(string)
  description = "Extra EC2 tags to add to the resulting AMI."
  default     = {}
}

variable "region" {
  type        = string
  description = "The region in which to build and upload the AMI. You must have a VPC deployed by the Imperva Unity AWS VPC module in this region."
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC you supplied when deploying the Imperva Unity AWS VPC module."
}

locals {
  template_source  = "github.com/imperva-marketing/pkr-unity-centos8"
  template_version = "0.1.0"
  release_date     = "13 May 2021"

  tag_prefix_domain = "impervaunity.io"
  build             = "{{isotime \"20060102.150405\"}}"
  build_date        = "{{isotime \"2006-01-02\"}}"
  build_time        = "{{isotime \"15:04:05\"}} UTC"
  vpc_tag           = "tag:aws.${local.tag_prefix_domain}/name"
  subnet_tag        = "tag:aws.${local.tag_prefix_domain}/subnet-type"
  image_name        = "${var.base_name}-${local.template_version}"
}

data "amazon-ami" "image" {
  filters = {
    virtualization-type = "hvm"
    architecture        = "x86_64"
    name                = "CentOS 8.*"
    root-device-type    = "ebs"
  }
  most_recent = true
  owners      = ["125523088429"]
  region      = var.region
}

source "amazon-ebs" "image" {
  region                  = var.region
  ami_name                = local.image_name
  ami_description         = "CentOS 8 image for Imperva Unity demos (Version: ${local.template_version}, Released: ${local.release_date}, Built: ${local.build_date} at ${local.build_time})"
  ami_virtualization_type = "hvm"
  ami_users               = var.extra_accounts
  ami_regions             = var.extra_regions
  force_deregister        = true
  tags = {
    Name                                                   = local.image_name
    "packer.${local.tag_prefix_domain}/managed"            = "true"
    "packer.${local.tag_prefix_domain}/base-name"          = var.base_name
    "packer.${local.tag_prefix_domain}/image-release-date" = local.release_date
    "packer.${local.tag_prefix_domain}/image-version"      = local.template_version
    "packer.${local.tag_prefix_domain}/image-build"        = local.build
    "packer.${local.tag_prefix_domain}/image-platform"     = "CentOS 8"
    "packer.${local.tag_prefix_domain}/template-source"    = local.template_source
    "packer.${local.tag_prefix_domain}/template-version"   = local.template_version
  }

  instance_type               = "t3.small"
  source_ami                  = data.amazon-ami.image.id
  associate_public_ip_address = true
  run_tags = {
    Name                                                   = local.image_name
    "packer.${local.tag_prefix_domain}/managed"            = "true"
    "packer.${local.tag_prefix_domain}/base-name"          = var.base_name
    "packer.${local.tag_prefix_domain}/image-release-date" = local.release_date
    "packer.${local.tag_prefix_domain}/image-version"      = local.template_version
    "packer.${local.tag_prefix_domain}/image-build"        = local.build
    "packer.${local.tag_prefix_domain}/image-platform"     = "CentOS 8"
    "packer.${local.tag_prefix_domain}/template-source"    = local.template_source
    "packer.${local.tag_prefix_domain}/template-version"   = local.template_version
  }
  run_volume_tags = {
    Name                                                   = local.image_name
    "packer.${local.tag_prefix_domain}/managed"            = "true"
    "packer.${local.tag_prefix_domain}/base-name"          = var.base_name
    "packer.${local.tag_prefix_domain}/image-release-date" = local.release_date
    "packer.${local.tag_prefix_domain}/image-version"      = local.template_version
    "packer.${local.tag_prefix_domain}/image-build"        = local.build
    "packer.${local.tag_prefix_domain}/image-platform"     = "CentOS 8"
    "packer.${local.tag_prefix_domain}/template-source"    = local.template_source
    "packer.${local.tag_prefix_domain}/template-version"   = local.template_version
  }
  subnet_filter {
    filters = {
      "tag:aws.${local.tag_prefix_domain}/vpc-name"        = var.vpc_name
      "tag:aws.${local.tag_prefix_domain}/internet-access" = "public"
    }
    most_free = true
  }
  temporary_iam_instance_profile_policy_document {
    Version = "2012-10-17"
    Statement {
      Effect = "Allow"
      Action = [
        "ssm:DescribeAssociation",
        "ssm:GetDeployablePatchSnapshotForInstance",
        "ssm:GetDocument",
        "ssm:DescribeDocument",
        "ssm:GetManifest",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:ListAssociations",
        "ssm:ListInstanceAssociations",
        "ssm:PutInventory",
        "ssm:PutComplianceItems",
        "ssm:PutConfigurePackageResult",
        "ssm:UpdateAssociationStatus",
        "ssm:UpdateInstanceAssociationStatus",
        "ssm:UpdateInstanceInformation",
        "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel",
        "ec2messages:AcknowledgeMessage",
        "ec2messages:DeleteMessage",
        "ec2messages:FailMessage",
        "ec2messages:GetEndpoint",
        "ec2messages:GetMessages",
        "ec2messages:SendReply"
      ]
      Resource = ["*"]
    }
  }
  vpc_filter {
    filters = {
      "tag:aws.${local.tag_prefix_domain}/name" = var.vpc_name
    }
  }

  ssh_username  = "centos"
  ssh_interface = "public_ip"
  communicator  = "ssh"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    encrypted             = false
    volume_size           = 10
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
    delete_on_termination = true
  }
}

build {
  name = "build-image"
  sources = [
    "source.amazon-ebs.image"
  ]
  provisioner "shell-local" {
    environment_vars = [
      "PLATFORM=aws-ec2"
    ]
    script = "${path.root}/build/package/upload.sh"
  }

  provisioner "file" {
    source      = "${path.root}/build/package/upload/"
    destination = "/tmp/"
  }

  provisioner "shell" {
    execute_command = "sudo -S /bin/bash -c '{{ .Vars }} {{ .Path }}'"
    inline = [
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh",
      "rm -f /tmp/*.sh /tmp/*.tar"
    ]
  }
}
