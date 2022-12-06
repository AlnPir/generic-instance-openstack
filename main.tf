terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.44.0"
    }
  }
}

provider "openstack" {
  auth_url          = var.auth_url
  region            = var.region
  user_name         = var.user_name
  password          = var.password
  user_domain_name  = var.user_domain_name
  project_domain_id = var.project_domain_id
  tenant_id         = var.tenant_id
  tenant_name       = var.tenant_name
}

resource "openstack_compute_secgroup_v2" "sg-web-front" {
  name        = "sg-web-front"
  description = "Security group for web front instances"

  rule {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

data "cloudinit_config" "base_config" {
  part {
    filename     = "base.yml"
    content_type = "text/cloud-config"
    content = templatefile("scripts/base.yml", {
      sshkey = var.sshkey
    })
  }
}

resource "openstack_compute_instance_v2" "instance" {
  name            = "instance"
  image_id        = "8db8bf5c-9962-41f9-a16c-a5d7b8e6055e" #opensuse
  flavor_name     = "a1-ram2-disk20-perf1"
  security_groups = ["sg-web-front"]
  user_data       = data.cloudinit_config.base_config.rendered
  metadata = {
    application = "instance"
  }
  network {
    name = "ext-net1"
  }
}
