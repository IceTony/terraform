variable "vm_name" {
  type            = "string"
  default         = "terr.ops8.test"
}

variable "vm_location" {
  type            = "string"
  default         = "msk0"
}

variable "vm_template" {
  type            = "string"
  default         = "ubuntu_18.04_64_001_master"
}

variable "vm_rplan" {
  type            = "string"
  default         = "medium"
}

variable "vm_user" {
  type            = "string"
  default         = "root"
}

provider "vscale" {
  token           = "my_vscale_token"
}

resource "random_string" "random_password" {
  length          = 16
  special         = false
}

resource "vscale_ssh_key" "icetony" {
  name            = "icetony.ssh.key"
  key             = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_scalet" "terr_ops8_test" {
  name            = "${var.vm_name}"
  location        = "${var.vm_location}"
  make_from       = "${var.vm_template}"
  rplan           = "${var.vm_rplan}"
  ssh_keys        = ["${vscale_ssh_key.icetony.id}"]
  
  provisioner "remote-exec" {
    inline        = [
      "echo \"root:${random_string.random_password.result}\" | chpasswd"
    ]
    
    connection {
      type        = "ssh"
      host        = "${vscale_scalet.terr_ops8_test.public_address}"
      user        = "${var.vm_user}"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}

output "ip" {
  value           = "${vscale_scalet.terr_ops8_test.public_address}"
}

