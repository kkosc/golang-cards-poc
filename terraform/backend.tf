terraform {
  required_version = ">= 1.1.9"
  backend "s3" {
    encrypt = "true"
    # bucket = "<input your bucket here or during terraform init>"
    # dynamodb_table = "<input here if you want to use state locking on ddb>"
    key = "cards-poc/main/terraform.tfstate"
  }
}
