resource "aws_route53_record" "domain" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${var.name}"
  type    = "CNAME"
  ttl     = "5"
  records = ["${aws_transfer_server.sftp.endpoint}"]
}

output "sftp-endpoint" {
  value = "${aws_transfer_user.sftp_user.user_name}@${aws_route53_record.domain.fqdn}"
}