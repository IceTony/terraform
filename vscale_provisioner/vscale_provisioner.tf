variable "vm_root_password" {
  type            = "string"
  default         = "Password123"
}

provider "vscale" {
  token           = "my_vscale_token"
}

resource "vscale_ssh_key" "icetony" {
  name            = "icetony.ssh.key"
  key             = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_scalet" "terr_ops7_test" {
  name            = "ops7.test"
  location        = "msk0"
  make_from       = "ubuntu_18.04_64_001_master"
  rplan           = "medium"
  ssh_keys        = ["${vscale_ssh_key.icetony.id}"]
  
  provisioner "remote-exec" {
    inline        = [
      "echo \"root:${var.vm_root_password}\" | chpasswd"
    ]
    
    connection {
      type        = "ssh"
      host        = "${vscale_scalet.terr_ops7_test.public_address}"
      user        = "root"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}

output "ip" {
  value           = "${vscale_scalet.terr_ops7_test.public_address}"
}

