provider "vscale" {
  token     = "my_vscale_token"
}

resource "vscale_ssh_key" "icetony" {
  name      = "icetony.ssh.key"
  key       = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_scalet" "terr_ops4_test" {
  count     = 1
  name      = "ops4.test"
  location  = "msk0"
  make_from = "ubuntu_16.04_64_001_master"
  rplan     = "medium"
  ssh_keys  = ["${vscale_ssh_key.icetony.id}"]
}
