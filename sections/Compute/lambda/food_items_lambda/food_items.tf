#lambda function
resource "aws_lambda_function" "order" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "food_items"
  role             = aws_iam_role.lambda_role.arn
  handler          = "fooditems.lambda_handler"
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
  source_dir  = "${path.module}/items_storage"
  output_path = "${path.module}/lambda/fooditems.zip"
}
