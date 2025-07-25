# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "my-kroger-instance"
  }

  
}

resource "null_resource" "send_curl_notification" {
  # This resource depends on other resources being created first.
  # For example, if you want to notify about a newly created EC2 instance:
  depends_on = [aws_instance.ubuntu]

  provisioner "local-exec" {
    command = <<EOT
curl -X POST "${var.cortex_callback}" -H "Content-Type: application/json"  -H "Authorization: Bearer ${var.cortex_token}" -d '{"status":"success", "message":"Finished","response":{"data":"${aws_instance.ubuntu.arn}"}}'
EOT
  }
}



