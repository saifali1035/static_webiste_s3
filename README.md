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
1. website.tf - main tf file and can be named anything , conatins s3 configuration and webiste configuration.
2. variable.tf - bucket name is set as variable so it can be easily renamed.
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



