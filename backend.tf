terraform {
  backend "s3" {
    bucket         = "traderev-tf-state-store"
    region         = "us-east-1"
    encrypt        = "true"
    dynamodb_table = "traderev-tf-locks"
    key            = "tf-tr-eks.tfstate"
  }
}
