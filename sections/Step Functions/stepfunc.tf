resource "aws_fd_purchase_process_machine" "step_function_machine" {
  name     = "StepFunctionMachine"
  role_arn = "arn:aws:iam::730335569978:role/service-role/StepFunctions-FD-PURCHASE-PROCESS-MACHINE-role-nkbxyfivf"

  definition = jsonencode({
    Comment = "A description of my state machine",
    StartAt = "Choice",
    States = {
      Choice = {
        Type = "Choice",
        Choices = [
          {
            Variable     = "$.type",
            StringEquals = "PURCHASE",
            Next         = "Purchase Handler"
          },
          {
            Variable     = "$.type",
            StringEquals = "REFUND",
            Next         = "Refund Handler"
          }
        ],
        Default = "Result Handler"
      },
      "Purchase Handler" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "Payload.$"  = "$",
          FunctionName = "arn:aws:lambda:us-east-2:730335569978:function:PurchaseHandler:$LATEST"
        },
        Retry = [
          {
            ErrorEquals = [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            IntervalSeconds = 1,
            MaxAttempts     = 3,
            BackoffRate     = 2
          }
        ],
        Next = "Result Handler"
      },
      "Result Handler" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "Payload.$"  = "$",
          FunctionName = "arn:aws:lambda:us-east-2:730335569978:function:ResultHandler:$LATEST"
        },
        Retry = [
          {
            ErrorEquals = [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            IntervalSeconds = 1,
            MaxAttempts     = 3,
            BackoffRate     = 2
          }
        ],
        End = true
      },
      "Refund Handler" = {
        Type       = "Task",
        Resource   = "arn:aws:states:::lambda:invoke",
        OutputPath = "$.Payload",
        Parameters = {
          "Payload.$"  = "$",
          FunctionName = "arn:aws:lambda:us-east-2:730335569978:function:RefundHandler:$LATEST"
        },
        Retry = [
          {
            ErrorEquals = [
              "Lambda.ServiceException",
              "Lambda.AWSLambdaException",
              "Lambda.SdkClientException",
              "Lambda.TooManyRequestsException"
            ],
            IntervalSeconds = 1,
            MaxAttempts     = 3,
            BackoffRate     = 2
          }
        ],
        Next = "Result Handler"
      }
    }
  })
}
