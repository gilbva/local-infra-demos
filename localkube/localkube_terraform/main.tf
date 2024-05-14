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
      agent = true
    }
}

data "local_file" "ssh_public_key" {
  filename = "/home/gilberto/.ssh/id_rsa.pub"
}

resource "proxmox_virtual_environment_vm" "kubemaster1" {
  name      = "kubemaster1"
  node_name = "pve0"

  initialization {
    ip_config {
      ipv4 {
        address = "10.7.4.100/24"
        gateway = "10.7.4.1"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [trimspace(data.local_file.ssh_public_key.content)]
    }
  }

  disk {
    datastore_id = "hdd0"
    file_id      = proxmox_virtual_environment_download_file.ubuntu_cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 80
  }

  network_device {
    bridge = "vmbr0"
  }
}

resource "proxmox_virtual_environment_download_file" "ubuntu_cloud_image" {
  content_type = "iso"
  datastore_id = "hdd0"
  node_name    = "pve0"

  url = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
}