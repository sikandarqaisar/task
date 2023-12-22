data "aws_iam_policy_document" "this" {
  
  version = var.VERSION
  dynamic "statement" {
    for_each = var.STATEMENTS
    content {
      actions      = statement.value.actions
      effect       = statement.value.effect
     principals {
          type                = statement.value.principals["type"] 
          identifiers         = statement.value.principals["identifiers"]
      
     }
    }
  }
}

resource "aws_iam_instance_profile" "this" {
  count      = var.CREATE_INSTANCE_PROFILE ? 1 : 0
  name = var.NAME
  role = aws_iam_role.this.name
}
resource "aws_iam_role" "this" {
  name               = var.NAME
  path               = var.PATH
  assume_role_policy = data.aws_iam_policy_document.this.json
  tags = merge(
    var.COMMON_TAGS,
    var.TAGS,
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.POLICIES_ARN) > 0 ? length(var.POLICIES_ARN) : 0
  role       = aws_iam_role.this.name
  policy_arn = var.POLICIES_ARN[count.index]
}


