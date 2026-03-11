
provider "aws" {
    region = "us-east-1"  
}

#This is s3 bucket

variable "bucket_names" {
  default = [
    "terraform-for-devops-urmi-new2",
    "terraform-for-devops-urmi-new3",
    "terraform-for-devops-urmi-new4"
  ]
}

resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.bucket_names)

  bucket = each.value
}
