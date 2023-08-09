#! /bin/bash
set -euxo pipefail

ANSIBLE_VERSION=6.2.0

# Install Ansible
pip3 install --user pywinrm ansible==${ANSIBLE_VERSION}

# Install bundler
gem install --user bundler --no-document
bundle install
