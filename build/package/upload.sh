#!/bin/bash -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [ -z "${PLATFORM}" ]; then
    echo "| ERROR | Please set the PLATFORM environment variable."
    exit 1
elif [ ! -e "${script_dir}/files/${PLATFORM}" ]; then
    echo "| ERROR | The PLATFORM '${PLATFORM}' is not valid."
    exit 1
fi

tar -cvf "${script_dir}/upload/packer-common.tar" -C "${script_dir}/files/common" .
tar -cvf "${script_dir}/upload/packer-${PLATFORM}.tar" -C "${script_dir}/files/${PLATFORM}" .
cp "${script_dir}/files/install.sh" "${script_dir}/upload/"
