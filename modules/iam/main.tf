resource "aws_iam_role" "this" {
  name        = "${var.iam_name}-Role"
  description = "IAM role for EC2 instance"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Action = "sts:AssumeRole"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
            Effect = "Allow"
        }
    ]
  })
}

resource "aws_iam_policy" "this" {
  name        = "${var.iam_name}-Policy"
  description = "IAM policy for EC2 instance"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ReadInitSqlFromS3"
        Effect = "Allow"

        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]

        Resource = [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Sid    = "ReadDatabaseSecret"
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = var.secret_arns
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.iam_name}-Profile"
  role = aws_iam_role.this.name
}