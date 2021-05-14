#!/bin/bash -e

# Setup variables
export STEP_CLI_VERSION=0.15.16
export STEP_CA_VERSION=0.15.14
echo "running as: $(whoami)"
sleep 5

# Update and install packages
dnf -y install epel-release
dnf -y update
dnf -y install \
  firewalld \
  jq \
  nvme-cli \
  python3 \
  python3-pip \
  python3-dnf-plugin-versionlock \
  traceroute \
  unzip
systemctl disable firewalld

# Install PIP packages
pip3 install --no-cache-dir --upgrade pip
pip3 install --no-cache-dir --upgrade \
  docker-compose \
  boto3 \
  yq \
  pyOpenSSL

# Install AWS CLI v2
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -d /tmp /tmp/awscliv2.zip
/tmp/aws/install

# Install AWS SSM agent
dnf install -y https://s3.us-east-2.amazonaws.com/amazon-ssm-us-east-2/latest/linux_amd64/amazon-ssm-agent.rpm

# Unpack files
for f in $(find /tmp -name packer-\*.tar); do
  tar --no-same-owner -xvf ${f} -C /
done
chmod +x \
  /usr/local/sbin/* \
  /usr/local/bin/*
semanage port -a -t ssh_port_t -p tcp 8222

# Install Docker CE
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf -y install docker-ce docker-ce-cli containerd.io
count=0
while [ -e /var/lib/rpm/.rpm.lock ]; do
  echo "waiting for RPM lock to be freed"
  ((count=count+1))
  if [ $count -lt 30 ]; then
    sleep 1
  else
    echo "timer expired - forcing RPM lock free"
    rm -rf /var/lib/rpm/.rpm.lock
  fi
done
systemctl enable docker

# Install smallstep clients
curl -LO "https://github.com/smallstep/cli/releases/download/v${STEP_CLI_VERSION}/step_linux_${STEP_CLI_VERSION}_amd64.tar.gz"
tar -xf "step_linux_${STEP_CLI_VERSION}_amd64.tar.gz" -C /tmp
cp "/tmp/step_${STEP_CLI_VERSION}/bin/step" /usr/bin
rm -f "step_linux_${STEP_CLI_VERSION}_amd64.tar.gz"

curl -LO "https://github.com/smallstep/certificates/releases/download/v${STEP_CA_VERSION}/step-ca_linux_${STEP_CA_VERSION}_amd64.tar.gz"
tar -xf "step-ca_linux_${STEP_CA_VERSION}_amd64.tar.gz" -C /tmp
cp "/tmp/step-ca_${STEP_CA_VERSION}/bin/step-ca" /usr/bin
rm -f "step-ca_linux_${STEP_CA_VERSION}_amd64.tar.gz"

# Update MOTD settings
rm -f /etc/motd.d/cockpit

# Change default 'centos' user to 'imperva'
sed -i 's|name: centos|name: imperva|g' /etc/cloud/cloud.cfg
sed -i 's|gecos: Cloud User|gecos: Imperva Admin|g' /etc/cloud/cloud.cfg
sed -i 's|centos|imperva|g' /etc/passwd
sed -i 's|Cloud User|imperva|g' /etc/passwd
sed -i 's|centos|imperva|g' /etc/shadow
sed -i 's|centos|imperva|g' /etc/group
mv /home/centos /home/imperva

# Update cloud configuration
sed -i 's|^preserve_hostname: false|preserve_hostname: true|g' /etc/cloud/cloud.cfg

# Update CA certificates
update-ca-trust extract

# Enable services
systemctl daemon-reload

# Do one final upgrade to make sure all packages are updated
dnf -y update
dnf -y autoremove

# Cleanup
rm -rf /etc/sudoers.d/90-cloud-init-users /root/.ssh/*.bak /home/imperva/.ssh/*.bak /tmp/* /var/tmp/*
cloud-init clean
> /home/imperva/.ssh/authorized_keys
> /root/.ssh/authorized_keys
history -c
