variable "devs" {
  type            = "list"
  default         = [
    "dev1.icetony",
    "dev2.icetony",
    "dev3.icetony"
  ]
}

data "aws_route53_zone" "srwx-net" {
  name            = "devops.rebrain.srwx.net."
  private_zone    = false
}

provider "vscale" {
  token           = "my_vscale_token"
}

provider "aws" {
  region          = "us-west-2"
  access_key      = "my_aws_token"
  secret_key      = "my_aws_token"
}

resource "random_string" "random_password" {
  count           = "${length(var.devs)}"
  length          = 16
  special         = false
}

resource "vscale_ssh_key" "icetony" {
  name            = "icetony.ssh.key"
  key             = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_ssh_key" "rebrain" {
  name            = "rebrain.ssh.pub.key"
  key             = "${file("~/.ssh/rebrain_ssh.pub")}"
}

resource "vscale_scalet" "icetony_ops_terr_9" {
  count           = "${length(var.devs)}"
  name            = "${element(var.devs, count.index)}.ops_terr_9"
  location        = "msk0"
  make_from       = "ubuntu_18.04_64_001_master"
  rplan           = "medium"
  ssh_keys        = ["${vscale_ssh_key.icetony.id}", "${vscale_ssh_key.rebrain.id}"]

  provisioner "remote-exec" {
    inline        = [
      "echo \"root:${element(random_string.random_password.*.result, count.index)}\" | chpasswd"
    ]
    
    connection {
      type        = "ssh"
      host        = "${self.public_address}"
      user        = "root"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}

resource "aws_route53_record" "icetony_dns" {
  count           = "${length(var.devs)}"
  zone_id         = "${data.aws_route53_zone.srwx-net.zone_id}"
  name            = "${element(var.devs, count.index)}.${data.aws_route53_zone.srwx-net.name}"
  type            = "A"
  ttl             = "300"
  records         = ["${element(vscale_scalet.icetony_ops_terr_9.*.public_address, count.index)}"]

  provisioner "local-exec" {
    command       = "echo ${element(var.devs, count.index)}.${data.aws_route53_zone.srwx-net.name} ${element(vscale_scalet.icetony_ops_terr_9.*.public_address, count.index)} ${element(random_string.random_password.*.result, count.index)} >> devs.txt"
  }
}
