# setup colors
NORMAL="\[\033[0m\]"
BLUE="\[\033[0;34m\]"
GREEN="\[\033[0;32m\]"
CYAN="\[\033[0;36m\]"
RED="\[\033[0;31m\]"
PURPLE="\[\033[0;35m\]"
DK_YELLOW="\[\033[0;33m\]"
LT_GRAY="\[\033[0;37m\]"
DK_GRAY="\[\033[1;30m\]"
LT_BLUE="\[\033[1;34m\]"
LT_GREEN="\[\033[1;32m\]"
LT_CYAN="\[\033[1;36m\]"
LT_RED="\[\033[1;31m\]"
LT_PURPLE="\[\033[1;35m\]"
YELLOW="\[\033[1;33m\]"
WHITE="\[\033[1;37m\]"

# setup environment prompt
env=()
if [ ! -z "${VM_CLOUD_ID}" ]; then
	cloud_id="${VM_CLOUD_ID}"
	if [ ! -z "${VM_RESOURCE_GROUP}" ]; then
		cloud_id="${cloud_id}/${VM_RESOURCE_GROUP}"
	fi
	env+=("${CYAN}${cloud_id}${NORMAL}")
fi
if [ ! -z "${VM_VPC_NAME}" ]; then
  env+=("${DK_YELLOW}${VM_VPC_NAME}${NORMAL}")
fi
if [ ! -z "${VM_ZONE}" ]; then
  env+=("${GREEN}${VM_ZONE}${NORMAL}")
fi
env=$(join_by '|' "${env[@]}")

hostname="\h"
if [ ! -z "${VM_NAME}" ]; then
  hostname="${VM_NAME}"
fi
if [ ! -z "${VM_HOSTNAME}" ]; then
  hostname="${VM_HOSTNAME}"
fi
if [ -z "$USER" -o "$USER" == "root" ]; then
  PS1="${NORMAL}[${env}] ${LT_PURPLE}${hostname}${NORMAL}:${LT_CYAN}\w${NORMAL}\n${LT_RED}\u #${NORMAL} "
else
  PS1="${NORMAL}[${env}] ${LT_PURPLE}${hostname}${NORMAL}:${LT_CYAN}\w${NORMAL}\n${LT_GREEN}\u \$${NORMAL} "
fi
