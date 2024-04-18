# static_webiste_s3
Hosting a static website on aws s3 with terraform


Webiste :-
![image](https://github.com/saifali1035/static_webiste_s3/assets/37189361/97345aa4-1b01-4595-ade4-c1642b23f2bb)

# Prerequisites
1. An aws account
2. Terraform and aws cli installed , or
3. Use git codespace with aws cli and terraform installed
4. Git cli installed ( Optional )
5. A website template from Templated.co ( As we are learning terraform and aws s3 here and not html )

# Dir Structure
![image](https://github.com/saifali1035/static_webiste_s3/assets/37189361/207e8432-a259-4b8c-ab15-019e34a9c914)

Hidden files can be ignored.
We will have 3 main terraform files , namely
1. variable.tf - bucket name is set as variable so it can be easily renamed.
2. website.tf - main tf file and can be named anything , conatins s3 configuration and webiste configuration.
3. output.tf - output file give us the URL.
We have one dir named web-files, which will have out website related files.

# variables.tf

```terraform
variable "my_bucket_name" {
    description = "my-static-web-18-April"
    type = string
    default = "demo-terraform-bucket18april2023"
}
```
We will start by creating our variable named **my_bucket_name**, as clear by name it will hold **the name of our s3 bucket**

# website.tf

```terraform
provider "aws" {
  region = "ap-south-1"
}
```
This can be a seperate file by itself with name **providers.tf**, i decided to add this in same file.

```terraform
resource "aws_s3_bucket" "website-saif" {
  bucket = var.my_bucket_name
}
```
Resource **s3 bucket** is defined with name **website-saif**, this name will be used throughout the file to use the bucket.

```terraform
resource "aws_s3_bucket_ownership_controls" "website-saif-ownership" {
  bucket = aws_s3_bucket.website-saif.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
```
![image](https://github.com/Tech-With-Helen/static-website-aws/assets/37189361/39fc5458-dbbf-4a96-aab3-926a85517108)

Resource **ownership control** is defined with name **website-saif-ownership**, bucket name is supplied and rule is set to **object_ownership = "BucketOwnerPreferred"** which means when objects will be added into bucket the owner will be bucket owner and not the object owner who added object into the bucket.

```terraform
resource "aws_s3_bucket_public_access_block" "website-saif-public" {
  bucket = aws_s3_bucket.website-saif.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
```
![image](https://github.com/Tech-With-Helen/static-website-aws/assets/37189361/be9b378b-8db0-4817-bac3-fb467da109a1)

Resource **public access block** is defined with name **website-saif-public**, bucket name is supplied and all 4 available options are set to **false** which are by default **true** which will **make the bucket public**.
You will see this red niotification on top of your bucket name which says its public.

![image](https://github.com/Tech-With-Helen/static-website-aws/assets/37189361/85c94ea2-257e-4f75-adc9-ce205cb92926)


```terraform
resource "aws_s3_bucket_acl" "website-saif-acl" {
  depends_on = [ 
    aws_s3_bucket_ownership_controls.website-saif-ownership,
    aws_s3_bucket_public_access_block.website-saif-public
   ]
   bucket = aws_s3_bucket.website-saif.id
   acl = "public-read"
}
```
![image](https://github.com/Tech-With-Helen/static-website-aws/assets/37189361/788d08c5-7ba0-4aae-94ee-5d1abccabd51)

Resource **Bucket acl** is defined with name **website-saif-acl**, bucket name is supplied and acl to set to **public-read** which means **anyone can list the objects from the bucket**
It depends on above two resources.


```terraform
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
```

```terraform
resource "aws_s3_bucket_website_configuration" "webiste-saif-config" {
  bucket = aws_s3_bucket.website-saif.id

  index_document {
    suffix = "index.html"
  }
}
```
![image](https://github.com/Tech-With-Helen/static-website-aws/assets/37189361/0dba06e5-5a87-4048-9c54-9ad2e9dcf9d2)

Resource **website configuration** is defined with name **website-saif-config**, bucket name is supplied and rule is set for index document with name as index.html.
Error document can also be defined but is optional.

```terraform
module "template_files" {
    source = "hashicorp/dir/template"

    base_dir = "${path.module}/web-files"
}
```

```terraform
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
```



