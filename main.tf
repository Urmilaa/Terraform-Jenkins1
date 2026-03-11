provider "aws" {
    region = "us-east-1"  
}

#This is s3 bucket
     
     
       resource "aws_s3_bucket" "my_bucket" {
         bucket = "terraform-for-devops-urmi-new2"
       }
