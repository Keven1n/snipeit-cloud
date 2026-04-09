provider "aws" {
  region = "us-east-1"
}

# Criador do Bucket para o Estado Remoto
resource "aws_s3_bucket" "terraform_state" {
  bucket = "snipeit-tfstate-560288546659"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB para o bloqueio e trava do Estado (Prevenção de Corrupção)
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "snipeit-terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
}
