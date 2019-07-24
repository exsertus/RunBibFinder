provider "aws" {
  region = "${var.region}"
  profile = "${var.profile}"
}

variable "region" {
  default = "eu-west-1"
}

variable "profile" {
  default = "default"
}

variable "name" {
  default = "bibfinder"
}

variable "domain" {
}

variable "user" {
  default = "user"
}

data "template_file" "pub_key" {
  template = "${file("~/.ssh/id_rsa.pub")}"
}

data "aws_caller_identity" "current" {}

data "aws_route53_zone" "zone" {
  name = "${var.domain}"
}