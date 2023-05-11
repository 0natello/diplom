terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token = "y0_AgAAAAAIU9bEAATuwQAAAADT4fD7D9rB-TcCTOe0pzJxCvo3hwmviNM"
  folder_id = "b1g1tlqv0fvid7ql562c" # идентификатор Вашей папки в Yandex.Cloud
  zone      = "ru-central1-a"
}

resource "yandex_vpc_network" "kubernetes-network" {
  name = "kubernetes-network"
}

resource "yandex_vpc_subnet" "kubernetes-subnet" {
  name           = "kubernetes-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.kubernetes-network.id
  v4_cidr_blocks = ["192.168.0.0/24"]
}

resource "yandex_compute_instance" "kubernetes-master" {
  name = "kubernetes-master"
  hostname = "kubernetes-master"
  boot_disk {
    initialize_params {
      image_id = "fd8gnpl76tcrdv0qsfko"
    }
  }
  resources {
    cores  = 2
    memory = 2
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kubernetes-subnet.id
    nat       = true
  }
  metadata = {
    user-data = "${file("/hdd/yandex/terraform/aldpro1/user.txt")}"
  }
    service_account_id = "aje6ciu80gds8r616jrq"
}

resource "yandex_compute_instance" "kubernetes-app" {
  name = "kubernetes-app"
  hostname = "kubernetes-app"
  boot_disk {
    initialize_params {
      image_id = "fd8gnpl76tcrdv0qsfko"
    }
  }
  resources {
    cores  = 2
    memory = 2
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kubernetes-subnet.id
    nat       = true
  }
  metadata = {
    user-data = "${file("/hdd/yandex/terraform/aldpro1/user.txt")}"
  }
    service_account_id = "aje6ciu80gds8r616jrq"
}

resource "yandex_compute_instance" "srv" {
  name = "srv"
  hostname = "srv"
  boot_disk {
    initialize_params {
      image_id = "fd8gnpl76tcrdv0qsfko"
    }
  }
  resources {
    cores  = 2
    memory = 2
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.kubernetes-subnet.id
    nat       = true
  }
  metadata = {
    user-data = "${file("/hdd/yandex/terraform/aldpro1/user.txt")}"
  }
    service_account_id = "aje6ciu80gds8r616jrq"
}

output "kubernetes-master-ip" {
  value = yandex_compute_instance.kubernetes-master.network_interface.0.nat_ip_address
}

output "kubernetes-app-ip" {
  value = yandex_compute_instance.kubernetes-app.network_interface.0.nat_ip_address
}

output "kubernetes-srv-ip" {
  value = yandex_compute_instance.srv.network_interface.0.nat_ip_address
}

resource "null_resource" "ansible_kubernetes-master" {
  depends_on = [yandex_compute_instance.kubernetes-master]
  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i '${yandex_compute_instance.kubernetes-master.network_interface[0].nat_ip_address}' --private-key '/home/user/.ssh/id_rsa' ansible/kubernetes-master.yml"
  }
}

resource "null_resource" "ansible_kubernetes-app" {
  depends_on = [yandex_compute_instance.kubernetes-app]
  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i '${yandex_compute_instance.kubernetes-app.network_interface[0].nat_ip_address}' --private-key '/home/user/.ssh/id_rsa' ansible/kubernetes-app.yml"
  }
}

resource "null_resource" "ansible_srv" {
  depends_on = [yandex_compute_instance.srv]
  provisioner "local-exec" {
    command = "sleep 10 && ansible-playbook -i '${yandex_compute_instance.srv.network_interface[0].nat_ip_address}' --private-key '/home/user/.ssh/id_rsa' ansible/srv.yml"
  }
}
