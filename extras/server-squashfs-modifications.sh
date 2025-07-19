#!/bin/bash

set -euxo pipefail

if ! ischroot -t; then
  echo "This script is intended to run within a chroot, to modify a squashfs image."
  exit 1
fi

echo 'nameserver 8.8.8.8' > /etc/resolv.conf

cp /etc/apt/sources.list /etc/apt/sources.list1
sed -i -E "s/(archive|security).ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list

apt-get update && \
  apt-get install -y dpkg-dev bash curl gpg lsb-core software-properties-common proxychains4 && \
#  sed -i -E 's/socks4.*9050/socks5         192.168.75.16 7896/g' /etc/proxychains4.conf && \
  # nvidia-container-toolkit
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | \
  gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg && \
  curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
  sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
  tee /etc/apt/sources.list.d/nvidia-container-toolkit.list && \
  # docker-ce
  curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | apt-key add - &&  \
  add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable" && \
  apt-get update && \
  apt-get install -y dpkg-dev mokutil efibootmgr tpm2-tools sox \
    git wget jq tree tar upx-ucl bzip2 zip unzip xz-utils rar unrar p7zip-full vim openssh-server net-tools build-essential g++ gcc gcc-12 make cmake libpam-cracklib \
    libglvnd-dev pkg-config language-pack-zh-hans language-pack-zh-hans-base nvidia-container-toolkit docker-ce \
    network-manager openresolv telnet openssl socat libseccomp-dev ipvsadm bind9 bind9utils bind9-doc dnsutils

curl -L "https://github.com/docker/compose/releases/download/v2.36.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

mv /etc/apt/sources.list1 /etc/apt/sources.list

#echo "FallbackDNS=8.8.8.8" >> /etc/systemd/resolved.conf
#echo "FallbackNTP=ntp.ubuntu.com" >> /etc/systemd/timesyncd.conf

# Clean up the image
echo ' ' > /etc/resolv.conf
rm -rf /tmp/* ~/.bash_history /var/lib/apt/lists/* /var/cache/apt/archives
apt clean
rm /var/lib/dbus/machine-id || true
exit