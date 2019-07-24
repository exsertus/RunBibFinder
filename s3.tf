#=========================================================================
# S3 Bucket
#=========================================================================

# Create private s3 bucket

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
  force_destroy = true
}

# Add inbox, matched and unmatched folders

resource "aws_s3_bucket_object" "inbox" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "inbox/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "matched" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "matched/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "unmatched" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "unmatched/"
  source = "/dev/null"
}

# Add the lambda event to the bucket's inbox to fire when files are uploaded

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.func.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "inbox/"
  }
}