# Provider, in this case AWS with credentials for account
provider "aws" {
  region                   = "us-west-1"
  shared_credentials_files = ["/Users/stephenhu/.aws/credentials"]
}

# IAM role for accessing lambda
resource "aws_iam_role" "lambda_role" {
  name               = "terraform_aws_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for lambda function with ability to create and update logs
resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing AWS lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# IAM policy Attachment on the role
resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Zip file for AWS lambda
data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/../src/"
  output_path = "${path.module}/../src/date-python.zip"
}

# Lambda function for getting current date and time
resource "aws_lambda_function" "terraform_lambda_date_function" {
  filename      = "${path.module}/../src/date-python.zip"
  function_name = "Get-Date-Function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "date-python.lambda_handler"
  runtime       = "python3.11"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
  source_code_hash = data.archive_file.zip_the_python_code.output_sha256
}

# Terraform outputs for AWS components
output "terraform_aws_role_output" {
  value = aws_iam_role.lambda_role.name
}

output "terraform_aws_role_arn_output" {
  value = aws_iam_role.lambda_role.arn
}

output "terraform_logging_arn_output" {
  value = aws_iam_policy.iam_policy_for_lambda.arn
}
