# tag names
tag_prefix_domain="impervaunity.io"
vpc_name_tag="aws.${tag_prefix_domain}/name"
instance_name_tag="aws.${tag_prefix_domain}/name"
hostname_tag="aws.${tag_prefix_domain}/hostname"
dns_suffix_tag="aws.${tag_prefix_domain}/dns-suffix"
resource_group_tag="aws.${tag_prefix_domain}/resource-group"

# common variables
export VM_CLOUD_ID="ec2"

# variables from metadata
export VM_INSTANCE_ID="$(getMetadata /instance-id)"
## IP information
export VM_PUBLIC_IP="$(getMetadata /public-ipv4)"
export VM_PRIVATE_IP="$(getMetadata /local-ipv4)"
## VPC information
mac_addr=($(getMetadata /network/interfaces/macs))
eth0_mac="${mac_addr[0]::-1}"
export VM_VPC_ID="$(getMetadata /network/interfaces/macs/${eth0_mac}/vpc-id)"
export VM_SUBNET_ID="$(getMetadata /network/interfaces/macs/${eth0_mac}/subnet-id)"
export VM_ZONE="$(getMetadata /placement/availability-zone)"
export VM_REGION="${VM_ZONE:0:-1}"
## Tag information
instance_tags="$(/usr/local/bin/aws ec2 describe-tags --filters Name=resource-id,Values=${VM_INSTANCE_ID} Name=resource-type,Values=instance --region ${VM_REGION})"
vpc_tags="$(/usr/local/bin/aws ec2 describe-tags --filters Name=resource-id,Values=${VM_VPC_ID} Name=resource-type,Values=vpc --region ${VM_REGION})"
export VM_NAME="$(echo ${instance_tags} | jq -r ".Tags[] | select (.Key == \"${instance_name_tag}\") | .Value")"
export VM_HOSTNAME="$(echo ${instance_tags} | jq -r ".Tags[] | select (.Key == \"${hostname_tag}\") | .Value")"
if [ -z "${VM_HOSTNAME}" ]; then
  export VM_HOSTNAME="$(hostname -s)"
fi
export VM_DNS_SUFFIX="$(echo ${instance_tags} | jq -r ".Tags[] | select (.Key == \"${dns_suffix_tag}\") | .Value")"
if [ -z "${VM_DNS_SUFFIX}" ]; then
  export VM_DNS_SUFFIX="$(hostname -d 2>/dev/null)"
fi
if [ ! -z "${VM_DNS_SUFFIX}" ]; then
  export VM_FQDN="${VM_HOSTNAME}.${VM_DNS_SUFFIX}"
else
  export VM_FQDN="${VM_HOSTNAME}"
fi
export VM_RESOURCE_GROUP="$(echo ${instance_tags} | jq -r ".Tags[] | select (.Key == \"${resource_group_tag}\") | .Value")"
export VM_VPC_NAME="$(echo ${vpc_tags} | jq -r ".Tags[] | select (.Key == \"${vpc_name_tag}\") | .Value")"
