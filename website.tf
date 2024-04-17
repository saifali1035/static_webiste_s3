provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "website-saif" {
  bucket = "website-saif"
}

resource "aws_s3_bucket_ownership_controls" "website-saif-ownership" {
  bucket = aws_s3_bucket.website-saif.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website-saif-public" {
  bucket = aws_s3_bucket.website-saif.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website-saif-acl" {
  depends_on = [ 
    aws_s3_bucket_ownership_controls.website-saif-ownership,
    aws_s3_bucket_public_access_block.website-saif-public
   ]
   bucket = aws_s3_bucket.website-saif.id
   acl = "public-read"
}

resource "aws_s3_bucket_policy" "host_bucket_policy" {
  bucket =  aws_s3_bucket.website-saif.id # ID of the S3 bucket

  # Policy JSON for allowing public read access
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource": "arn:aws:s3:::website-saif/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "webiste-saif-config" {
  bucket = aws_s3_bucket.website-saif.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_object" "website-saif-object" {
 bucket = aws_s3_bucket.website-saif.id

 key = "index.html"
 source = "./index.html"
}