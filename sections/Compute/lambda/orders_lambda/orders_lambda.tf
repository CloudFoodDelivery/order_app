#lambda function
resource "aws_lambda_function" "order" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "orders"
  role             = aws_iam_role.lambda_role.arn
  handler          = "orders.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

#iam role policy attachment
resource "aws_iam_role_policy_attachment" "lambda-iam-policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#acheive file data source
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/orders_dependency"
  output_path = "${path.module}/lambda/orders.zip"
}
