# What

Terraform code to deploy infrastructure ready to host the test-app.

## How

Before using it, review values in the `terraform.tfvars` file and then configure your authentication method for the AWS Terraform provider. You can use whatever you prefer (environment variables, shared credentials file, or [other](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)).

Then you can call `terraform plan`, `terraform apply` and other operations, as needed.
