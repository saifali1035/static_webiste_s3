provider "aws" {
  region = "ap-south-1"
}

resource "aws_s3_bucket" "website-saif" {
  bucket = var.my_bucket_name
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
        "Resource": "arn:aws:s3:::${var.my_bucket_name}/*"
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


module "template_files" {
    source = "hashicorp/dir/template"

    base_dir = "${path.module}/web-files"
}

resource "aws_s3_object" "Bucket_files" {
  bucket =  aws_s3_bucket.website-saif.id  # ID of the S3 bucket

  for_each     = module.template_files.files
  key          = each.key
  content_type = each.value.content_type

  source  = each.value.source_path
  content = each.value.content

  # ETag of the S3 object
  etag = each.value.digests.md5
}