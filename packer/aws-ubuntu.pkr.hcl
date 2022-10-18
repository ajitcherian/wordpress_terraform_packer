packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}
variable "ami_prefix" {
  type    = string
  default = "learn-packer-linux-aws-redis"
}

source "amazon-ebs" "ubuntu" {
  ami_name = "${var.ami_prefix}-${local.timestamp}"
  tags = {
    OS_Version    = "Ubuntu"
    Release       = "22.04"
    Base_AMI_Name = "${var.ami_prefix}-${local.timestamp}"
  }
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
}


build {
  name = "packer-wordpress-ami"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "file" {
    source      = "./utils/script.sh"
    destination = "/home/ubuntu/script.sh"
  }
  provisioner "file" {
    source      = "./utils/wordpress.conf"
    destination = "/home/ubuntu/wordpress.conf"
  }

  provisioner "shell" {
    inline = [
      "sudo chmod +x /home/ubuntu/script.sh",
      "echo Running script",
      "cd /home/ubuntu",
      "sudo /home/ubuntu/script.sh",
      "sudo rm script.sh",
    ]
  }
  provisioner "shell" {
    inline = ["echo `this provisoner runs at last`"]
  }

}
