#=========================================================================
# Lambda event function
#=========================================================================

# Setup role to allow S3 to execute this lambda function

resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.name}_lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}


# Setup policy to allow lambda function to execute cloudwatch and rekognition

resource "aws_iam_role_policy" "lambda_policy" {
  role = "${aws_iam_role.iam_for_lambda.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "logs:*",
      "Resource": "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    },
    {
      "Effect": "Allow",
      "Action": "rekognition:DetectText",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "${aws_s3_bucket.bucket.arn}/*"
    }
  ]
}
EOF
}


# Give permissions for s3 bucket to call the lambda function

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.func.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}

# Zip up lamdba function

data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "func" {
  filename      = "lambda.zip"
  function_name = "${var.name}-oncreate"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "lambda_function.oncreate_event"
  runtime       = "python3.6"
}