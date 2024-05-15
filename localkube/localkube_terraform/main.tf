terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.51.0"
    }
  }
}

provider "proxmox" {
    endpoint = "https://10.7.4.10:8006/"
    username = "root@pam"
    password = "vagrant"
    insecure = true
    ssh {
      username = "root"
      password = "vagrant"
    }
}

data "local_file" "ssh_public_key" {
  filename = "/home/gilberto/.ssh/id_rsa.pub"
}

variable "servers" {
  type = map(object({
    host = string,
    ip   = string,
    node = string,
    disk = string
  }))
  default = {
    kmaster1 = { host = "kmaster1", ip = "10.7.4.100", node = "pve0", disk = "hdd0" }
    kmaster2 = { host = "kmaster2", ip = "10.7.4.101", node = "pve0", disk = "hdd0" }
    kmaster3 = { host = "kmaster3", ip = "10.7.4.102", node = "pve0", disk = "hdd0" }
    knode1   = { host = "knode1",   ip = "10.7.4.103", node = "pve1", disk = "hdd0" }
    knode2   = { host = "knode2",   ip = "10.7.4.104", node = "pve2", disk = "hdd0" }
    knode3   = { host = "knode3",   ip = "10.7.4.105", node = "pve1", disk = "hdd0" }
    knode4   = { host = "knode4",   ip = "10.7.4.106", node = "pve2", disk = "hdd0" }
    knode5   = { host = "knode5",   ip = "10.7.4.107", node = "pve1", disk = "hdd0" }
    knode6   = { host = "knode6",   ip = "10.7.4.108", node = "pve2", disk = "hdd0" }
  }
}

variable "pves" {
  type = map(object({
    disk   = string,
  }))
  default = {
    "pve0" = { disk = "hdd0" }
    "pve1" = { disk = "hdd0" }
    "pve2" = { disk = "hdd0" }
  }
}

resource "proxmox_virtual_environment_vm" "kubemasters" {
  for_each = var.servers
    name      = "${each.value["host"]}"
    node_name = "${each.value["node"]}"

    cpu {
      cores = 1
    }

    memory {
      dedicated = 2048
    }

    initialization {
      ip_config {
        ipv4 {
          address = "${each.value["ip"]}/24"
          gateway = "10.7.4.1"
        }
      }

      user_account {
        username = "ubuntu"
        keys     = [trimspace(data.local_file.ssh_public_key.content)]
      }
    }

    disk {
      datastore_id = each.value.disk
      file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image[each.value.node].id
      interface    = "virtio0"
      iothread     = true
      discard      = "on"
      size         = 80
    }

    network_device {
      bridge = "vmbr1"
    }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  for_each = var.pves
    content_type = "iso"
    datastore_id = each.value.disk
    node_name    = each.key

    url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}