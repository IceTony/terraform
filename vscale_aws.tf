data "aws_route53_zone" "srwx-net" {
  name         = "devops.rebrain.srwx.net."
  private_zone = false
}

provider "vscale" {
  token        = "my_vscale_token"
}

provider "aws" {
  region       = "us-west-2"
}

resource "vscale_ssh_key" "icetony" {
  name         = "icetony.ssh.key"
  key          = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_ssh_key" "rebrain" {
  name         = "rebrain.ssh.pub.key"
  key          = "${file("~/.ssh/rebrain_ssh.pub")}"
}

resource "vscale_scalet" "terr_ops5_test" {
  name         = "ops5.test"
  location     = "msk0"
  make_from    = "ubuntu_18.04_64_001_master"
  rplan        = "medium"
  ssh_keys     = ["${vscale_ssh_key.icetony.id}", "${vscale_ssh_key.rebrain.id}"]
}

resource "aws_route53_record" "icetony_dns" {
  zone_id      = "${data.aws_route53_zone.srwx-net.zone_id}"
  name         = "icetony.devops.rebrain.srwx.net"
  type         = "A"
  ttl          = "300"
  records      = ["${vscale_scalet.terr_ops5_test.public_address}"]
}
