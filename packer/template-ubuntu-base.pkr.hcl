variable "project_id" {
  type    = string
  default = env("PROJECT_ID")
}

variable "service_account_email" {
  type    = string
  default = "packer@${env("PROJECT_ID")}.iam.gserviceaccount.com"
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "network" {
  type    = string
  default = env("NETWORK")
}

variable "image_family" {
  type    = string
  default = env("IMAGE_FAMILY")
}

variable "source_image_family" {
  type    = string
  default = env("SOURCE_IMAGE_FAMILY")
}

variable "source_image_project" {
  type    = string
  default = env("SOURCE_IMAGE_PROJECT")
}

variable "subnetwork" {
  type    = string
  default = env("SUBNETWORK")
}

variable "zone" {
  type    = string
  default = env("ZONE")
}

source "googlecompute" "ubuntu-base" {
  disk_type                   = "pd-balanced"
  enable_integrity_monitoring = true
  enable_secure_boot          = true
  enable_vtpm                 = true
  image_family                = var.image_family
  image_name                  = "${var.image_family}-${lower(replace(timestamp(), ":", "-"))}"
  image_storage_locations     = ["us"]
  machine_type                = var.machine_type
  metadata = {
    enable-oslogin = "TRUE"
    user-data      = "#cloud-config\npackage_update: false\npackage_upgrade: false"
  }
  network                 = var.network
  omit_external_ip        = true
  project_id              = var.project_id
  scopes                  = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account_email   = var.service_account_email
  source_image_family     = var.source_image_family
  source_image_project_id = [var.source_image_project]
  ssh_username            = "ubuntu"
  subnetwork              = var.subnetwork
  use_internal_ip         = true
  use_iap                 = true
  zone                    = var.zone
}

build {
  sources = ["source.googlecompute.ubuntu-base"]

  provisioner "shell" {
    inline = ["while sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do sleep 5; done"]
  }

  provisioner "ansible" {
    ansible_env_vars = ["ANSIBLE_CONFIG=./ansible/playbooks/ansible-linux.cfg"]
    playbook_file    = "./ansible/playbooks/ubuntu-base.yaml"
    user             = "ubuntu"
    extra_arguments = [
      "-e", "env=prod",
    ]
  }

  post-processor "manifest" {
    output     = "packer_output.json"
    strip_path = true
  }
}
