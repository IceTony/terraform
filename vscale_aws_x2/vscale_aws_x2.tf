variable "domains" {
  type         = "list"
  default      = ["icetony-1", "icetony-2"]
}

data "aws_route53_zone" "srwx-net" {
  name         = "devops.rebrain.srwx.net."
  private_zone = false
}

provider "vscale" {
  token        = "my_vscale_token"
}

provider "aws" {
  region       = "us-west-2"
  access_key   = "my_aws_token"
  secret_key   = "my_aws_token"
}

resource "vscale_ssh_key" "icetony" {
  name         = "icetony.ssh.key"
  key          = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_ssh_key" "rebrain" {
  name         = "rebrain.ssh.pub.key"
  key          = "${file("~/.ssh/rebrain_ssh.pub")}"
}

resource "vscale_scalet" "icetony_ops_terr_6" {
  count        = "${length(var.domains)}"
  name         = "${element(var.domains, count.index)}.ops_terr_6"
  location     = "msk0"
  make_from    = "ubuntu_18.04_64_001_master"
  rplan        = "medium"
  ssh_keys     = ["${vscale_ssh_key.icetony.id}", "${vscale_ssh_key.rebrain.id}"]
}

resource "aws_route53_record" "icetony_dns" {
  count        = "${length(var.domains)}"
  zone_id      = "${data.aws_route53_zone.srwx-net.zone_id}"
  name         = "${element(var.domains, count.index)}.${data.aws_route53_zone.srwx-net.name}"
  type         = "A"
  ttl          = "300"
  records      = ["${element(vscale_scalet.icetony_ops_terr_6.*.public_address, count.index)}"]
}

