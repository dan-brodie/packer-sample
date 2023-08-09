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

source "googlecompute" "windows-base" {
  communicator                = "winrm"
  disk_size                   = "128"
  disk_type                   = "pd-balanced"
  enable_integrity_monitoring = true
  enable_secure_boot          = true
  enable_vtpm                 = true
  image_family                = var.image_family
  image_name                  = "${var.image_family}-${lower(replace(timestamp(), ":", "-"))}"
  image_storage_locations     = ["us"]
  machine_type                = var.machine_type
  metadata = {
    windows-startup-script-cmd = "winrm quickconfig -quiet & net user /add packer & net localgroup administrators packer /add & winrm set winrm/config/service/auth @{Basic=\"true\"} & netsh advfirewall set allprofiles state off"
  }
  network                  = var.network
  windows_password_timeout = "15m" # pragma: allowlist secret
  pause_before_connecting  = "5m"
  omit_external_ip         = true
  project_id               = var.project_id
  scopes                   = ["https://www.googleapis.com/auth/cloud-platform"]
  service_account_email    = var.service_account_email
  source_image_family      = var.source_image_family
  source_image_project_id  = [var.source_image_project]
  subnetwork               = var.subnetwork
  use_internal_ip          = true
  use_iap                  = true
  winrm_insecure           = true
  winrm_use_ssl            = true
  winrm_username           = "packer"
  zone                     = var.zone
}

build {
  sources = ["source.googlecompute.windows-base"]

  provisioner "ansible" {
    playbook_file = "./ansible/playbooks/windows-base.yaml"
    timeout       = "45m0s"
    use_proxy     = false
    user          = "packer"
  }

  provisioner "powershell" {
    inline       = ["GCESysprep -NoShutdown"]
    pause_before = "15m"
  }

  post-processor "manifest" {
    output     = "packer_output.json"
    strip_path = true
  }
}
