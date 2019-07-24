resource "aws_transfer_server" "sftp" {
  identity_provider_type = "SERVICE_MANAGED"
}

resource "aws_iam_role" "role" {
  name = "sftp-user-iam-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy" {
  name = "sftp-user-iam-policy"
  role = "${aws_iam_role.role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "${aws_s3_bucket.bucket.arn}/*"
        }
    ]
}
EOF
}

resource "aws_transfer_user" "sftp_user" {
  server_id = "${aws_transfer_server.sftp.id}"
  user_name = "${var.user}"
  home_directory = "/${aws_s3_bucket.bucket.id}"
  role      = "${aws_iam_role.role.arn}"
}

resource "aws_transfer_ssh_key" "key" {
  server_id = "${aws_transfer_server.sftp.id}"
  user_name = "${aws_transfer_user.sftp_user.user_name}"
  body      = "${data.template_file.pub_key.rendered}"
}