locals {
  sysmon_config            = "sysmonconfig-export.xml"
  sysmon_zip               = "Sysmon.zip"
}

# Upload SwiftOnSecurity Sysmon configuration xml file
resource "aws_s3_object" "sysmon_config" {
  bucket = aws_s3_bucket.staging.id
  key    = "${local.sysmon_config}"
  source = "${path.module}/files/sysmon/${local.sysmon_config}"
}

# Upload Sysmon zip
resource "aws_s3_object" "sysmon_zip" {
  bucket = aws_s3_bucket.staging.id
  key    = "${local.sysmon_zip}"
  source = "${path.module}/files/sysmon/${local.sysmon_zip}"
}

output "object_s3_uri_sysmon_config" {
  value = "s3://${aws_s3_object.sysmon_config.bucket}/${aws_s3_object.sysmon_config.key}"
}

output "object_s3_uri_sysmon_zip" {
  value = "s3://${aws_s3_object.sysmon_zip.bucket}/${aws_s3_object.sysmon_zip.key}"
}