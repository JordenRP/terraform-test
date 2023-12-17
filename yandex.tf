terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "user" {
  type        = string
  default     = "pavel"
}

provider "yandex" {
  service_account_key_file = "/home/pavel/infra/teraform/key.json"
  folder_id		   = "b1gmhu9tc3bld5appt8p"
  zone                     = "ru-central1-a"
}

data "yandex_vpc_subnet" "default_a" {
  name = "default-ru-central1-a"  # одна из дефолтных подсетей
} 

resource "yandex_compute_instance" "default" {
  name        = "test-2"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = "fd8clogg1kull9084s9o"
      size = 50
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default_a.subnet_id
    nat = true    
  }

  metadata = {
      user-data = "${file("meta.txt")}"
      ssh-keys = "pavel:${file("~/.ssh/id_rsa.pub")}"
  }

  provisioner "local-exec" {
      when    = create
      command = "sleep 60 && echo ${self.network_interface.0.nat_ip_address} > public_ip.txt && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user} -i '${self.network_interface.0.nat_ip_address},' --private-key ~/.ssh/id_rsa ansible/playbook.yml"
  }
}
