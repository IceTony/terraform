variable "gitlab_token" {
  type    = "string"
  default = "my_token"
}

variable "gitlab_url" {
  type    = "string"
  default = "https://gitlab.rebrainme.com/api/v4"
}

provider "gitlab" {
  base_url = "${var.gitlab_url}"
  token    = "${var.gitlab_token}"
}

resource "gitlab_project" "ops_terraform_1" {
  name     = "ops_terraform_1"
  visibility_level = "private"
  default_branch = "master"
}

resource "gitlab_deploy_key" "gitlab_deploy_key" {
  project = "icetony/ops_terraform_1"
  title   = "Gitlab deploy key"
  can_push = "true"
  key     = "my_ssh_key"
  depends_on = [gitlab_project.ops_terraform_1]
}
