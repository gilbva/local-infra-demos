terraform {
  required_providers {
    libvirt = {
        source = "dmacvicar/libvirt"
        version = "0.7.6"
    }
  }
}

provider "libvirt" {
    uri = "qemu:///system"
}

variable "servers" {
  type = map(object({
    host = string,
    ip   = string
  }))
  default = {
    proxy1 = { host = "proxy1", ip = "10.17.31.21" }
    proxy2 = { host = "proxy2", ip = "10.17.31.22" }
    proxy3 = { host = "proxy3", ip = "10.17.31.23" }
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_network" "locallabnet" {
  name      = "locallab-net1"
  mode      = "nat"
  domain    = "locallab.tests"
  addresses = ["10.17.31.0/24"]
  dhcp {
    enabled = false
  }
  dns {
    enabled    = true
    local_only = false
  }
}

resource "libvirt_volume" "volumnes" {
    for_each = var.servers
        name = "${each.value["host"]}.qcow2"
        #pool = "hdd16"
        source = "/var/lib/libvirt/images/noble-server-cloudimg-amd64.img"
        format = "qcow2"
}

resource "libvirt_domain" "k3snodes" {
    for_each = var.servers
        name       = "${each.key}"
        memory     = 4096
        vcpu       = 2
        qemu_agent = false
        cloudinit  = libvirt_cloudinit_disk.commoninit.id

        network_interface {
            network_id     = libvirt_network.locallabnet.id
            addresses      = [each.value["ip"]]
            hostname       = "${each.value["host"]}"
            wait_for_lease = true
        }

        disk {
            volume_id = libvirt_volume.volumnes[each.value["host"]].id
        }

        console {
            type         = "pty"
            target_type  = "serial"
            target_port  = "0"
        }

        graphics {
            type           = "vnc"
            listen_type    = "address"
            listen_address = "0.0.0.0"
            autoport       = true
        }
}