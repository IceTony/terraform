provider "google" {
  credentials = "${file("~/.tokens/google_cloud.json")}"
  project = "rebrain"
  region      = "us-central1"
  zone         = "us-central1-a"
}

resource "google_compute_instance" "icetony_vm" {
  name         = "icetony"
  machine_type = "custom-2-8192"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
      size  = "20"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    ssh-keys = "root:${file("~/.ssh/id_rsa.pub")}"
  }
}

output "compute_instance_external_ip_addresses" {
    value       = "${google_compute_instance.icetony_vm.*.network_interface.0.access_config.0.nat_ip}"
}
