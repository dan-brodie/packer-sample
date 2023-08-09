# `atd-packer` README

## Prerequisites

### Networking

*   Packer is creating private VMs (w/o associated public IPs) so those VMs
would need **a NAT gateway** in case they want to access external resources
(e.g. running aptitude or other downloads etc.)
*   (For Windows) Ensure **WinRM traffic** is whitelisted (TCP 5986) in the VPC
where you'll be building images (or running Test Kitchen).

### Project-level IAM permissions

*   Create a service account called `packer`
*   Grant the following roles to `packer`:
    *   `roles/compute.osAdminLogin`
    *   `roles/iap.tunnelResourceAccessor`
    *   `roles/compute.instanceAdmin.v1`

### For running Packer via Cloud Build

*   Grant `roles/compute.instanceAdmin.v1` to the Cloud Build service account
*   Grant `roles/iam.serviceAccountUser` to the Cloud Build service account on
the new service account

## Building images

To run Packer via Cloud Build, first set your user auth credentials and set
your default project, then upload the Packer image to your project's GCR:

```sh
cd cloudbuild/runner
gcloud builds submit
```

Then run:

```sh
gcloud builds submit --config cloudbuild/ubuntu-base.yaml
```

To launch a VM from the resulting image:

```sh
gcloud beta compute instances create my-instance \
  --project PROJECT_ID \
  --zone europe-west1-b \
  --image-family PROJECT_NAME-ubuntu-base
```

## Running Test Kitchen

There are default test suites with basic validation for the VMs which you
~~can~~ should run in order to validate your VM images.

The following command will get you started:

```sh
gcloud auth application-default login
kitchen test \
  --destroy always \
  --concurrency 2
```
