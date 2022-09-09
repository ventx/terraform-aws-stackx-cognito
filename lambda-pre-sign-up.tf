data "aws_iam_policy_document" "assume_pre_sign_up" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "pre_sign_up" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards
  }

  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"] #tfsec:ignore:aws-iam-no-policy-wildcards
  }
}

resource "aws_iam_policy" "pre_sign_up" {
  name = substr(lower("pre-sign-up-${var.name}${var.static_unique_id != "" ? "-" : ""}${var.static_unique_id != "" ? var.static_unique_id : ""}"), 0, 63)

  policy = data.aws_iam_policy_document.pre_sign_up.json

  tags = local.tags
}


resource "aws_iam_role" "pre_sign_up" {
  name               = substr(lower("pre-sign-up-${var.name}${var.static_unique_id != "" ? "-" : ""}${var.static_unique_id != "" ? var.static_unique_id : ""}"), 0, 63)
  assume_role_policy = data.aws_iam_policy_document.assume_pre_sign_up.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "pre_sign_up" {
  role       = aws_iam_role.pre_sign_up.name
  policy_arn = aws_iam_policy.pre_sign_up.arn
}

resource "aws_lambda_permission" "pre_sign_up" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_sign_up.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.pool.arn
}

#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "pre_sign_up" {
  function_name = substr(lower("pre-sign-up-${var.name}${var.static_unique_id != "" ? "-" : ""}${var.static_unique_id != "" ? var.static_unique_id : ""}"), 0, 63)

  role             = aws_iam_role.pre_sign_up.arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  filename         = "${path.module}/function/pre-sign-up/function.zip"
  publish          = false
  source_code_hash = filebase64sha256("${path.module}/function/pre-sign-up/function.zip")
  memory_size      = 128
  timeout          = 15

  environment {
    variables = {
      DOMAINALLOWLIST = var.domain_allow_list
      MODULES         = "email-filter-allowlist"
    }
  }

  tags = local.tags
}
