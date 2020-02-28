variable "domains" {
  type         = "list"
  default      = ["swarm1", "swarm2", "swarm3"]
}

variable "vm_root_password" {
  type            = "string"
  default         = "password"
}

data "aws_route53_zone" "srwx-net" {
  name         = "devops.rebrain.srwx.net."
  private_zone = false
}

variable "hcloud_token" {
  type        = "string"
  default     = "<hetzner_token>"
}

provider "hcloud" {
  token       = "${var.hcloud_token}"
}

provider "aws" {
  region       = "us-west-2"
  access_key = "<aws_token>"
  secret_key = "<aws_token>"
}

resource "hcloud_ssh_key" "icetony_ssh_key" {
  name        = "ICETONY.SSH.PUB.KEY"
  public_key  = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "icetony_server" {
  count       = "${length(var.domains)}"
  image       = "ubuntu-18.04"
  name        = "${element(var.domains, count.index)}.icetony"
  server_type = "cx21"
  ssh_keys    = [
  "${hcloud_ssh_key.icetony_ssh_key.id}"
  ]

#  provisioner "remote-exec" {
#    inline        = [
#      "echo \"root:${var.vm_root_password}\" | chpasswd",
#      "apt update && apt install vim curl mc git -y"
#    ]

#    connection {
#      type        = "ssh"
#      host        = "${element(digitalocean_droplet.icetony_droplet.*.ipv4_address, count.index)}"
#      user        = "root"
#      private_key = "${file("~/.ssh/id_rsa")}"
#    }
#  }
}

resource "aws_route53_record" "icetony_dns" {
  count        = "${length(var.domains)}"
  zone_id      = "${data.aws_route53_zone.srwx-net.zone_id}"
  name         = "${element(var.domains, count.index)}.${data.aws_route53_zone.srwx-net.name}"
  type         = "A"
  ttl          = "300"
  records      = ["${element(hcloud_server.icetony_server.*.ipv4_address, count.index)}"]
}
