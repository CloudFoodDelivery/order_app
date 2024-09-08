# Lambda function
resource "aws_lambda_function" "customer_function" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "order_items_function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "orderItems.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}


resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Archive file data source
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/OrderItemsLambda"
  output_path = "${path.module}/orderItems.zip"
}
