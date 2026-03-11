variable "bucket_names" {
  default = [
    "terraform-for-devops-urmi-new2",
    "terraform-for-devops-urmi-new3"
  ]
}

resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  bucket = each.value
}
