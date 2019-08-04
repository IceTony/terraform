variable "do_token" {
  type        = "string"
  default     = "my_token"
}

provider "digitalocean" {
  token       = "${var.do_token}"
}

resource "digitalocean_ssh_key" "icetony_ssh_key" {
  name        = "ICETONY.SSH.PUB.KEY"
  public_key  = "${file("~/.ssh/id_rsa.pub")}"
}

data "digitalocean_ssh_key" "rebrain_ssh_key" {
  name        = "REBRAIN.SSH.PUB.KEY"
}

resource "digitalocean_droplet" "icetony_ops_2" {
  image       = "ubuntu-18-04-x64"
  name        = "icetony-ops-2"
  region      = "fra1"
  size        = "s-1vcpu-1gb"
  ssh_keys    = [
  "${digitalocean_ssh_key.icetony_ssh_key.fingerprint}",
  "${data.digitalocean_ssh_key.rebrain_ssh_key.fingerprint}"
]
}

output "ip" {
  value       = "${digitalocean_droplet.icetony_ops_2.ipv4_address}"
}
