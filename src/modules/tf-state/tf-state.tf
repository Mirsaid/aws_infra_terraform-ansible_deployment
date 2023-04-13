resource "aws_s3_bucket" "tfstate_bucket" {
  bucket = var.bucket_name
    lifecycle {
    prevent_destroy = true
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate_bucket_sse_config" {
  bucket  = aws_s3_bucket.tfstate_bucket.id

  rule {    
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
      lifecycle {
    prevent_destroy = true
  }

  
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name           = var.db_name
  hash_key       = "LockID"
  billing_mode   = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
    lifecycle {
    prevent_destroy = true
  }
}
