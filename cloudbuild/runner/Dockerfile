# Basing on cloud SDK for IAP tunnel creations to work
FROM google/cloud-sdk:alpine

ARG PACKER_VERSION
ARG ANSIBLE_VERSION

RUN apk add --update openssh-client curl py3-pip && rm -rf /var/cache/apk/*

RUN curl -sSL https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_$(dpkg --print-architecture).zip > packer_${PACKER_VERSION}_linux_$(dpkg --print-architecture).zip && \
  unzip packer_${PACKER_VERSION}_linux_$(dpkg --print-architecture).zip -d /usr/bin && \
  rm -f packer_${PACKER_VERSION}_linux_$(dpkg --print-architecture).zip

RUN pip3 install \
  ansible==${ANSIBLE_VERSION} \
  pywinrm
