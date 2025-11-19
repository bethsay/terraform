resource "aws_s3_bucket" "first" {
  bucket = "tf-unique-bucket"

  tags = {
    project = "training"
    env     = "dev"
  }
}
