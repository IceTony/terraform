# Установка vscale-плагина для terraform
1. Установить golang:  
```sudo apt install golang```
2. Скачиваем репозитрий (например в домашнюю дирректорию):  
```cd ~```  
```go get -u github.com/burkostya/terraform-provider-vscale```
3. Скопировать собранный бинарный файл в папку ~/.terraform.d/plugins/  
```mkdir -p ~/.terraform.d/plugins```  
```cp ~/go/bin/terraform-provider-vscale ~/.terraform.d/plugins```
4. Для проверки создаем файл vscale.tf с содержанием:
```
provider "vscale" {
  token     = "my_vscale_token"
}

resource "vscale_ssh_key" "my_ssh_key" {
  name      = "my.ssh.key"
  key       = "${file("~/.ssh/id_rsa.pub")}"
}

resource "vscale_scalet" "my_vscale_scalet" {
  count     = 1
  name      = "my.vscale.scalet"
  location  = "msk0"
  make_from = "ubuntu_16.04_64_001_master"
  rplan     = "medium"
  ssh_keys  = ["${vscale_ssh_key.my_ssh_key.id}"]
}
```
... и выполняем команды:  
```terraform init```  
```terraform apply```