resource "aws_iam_policy" "this" {
  name        = var.NAME
  path        = var.PATH
  description = var.DESCRIPTION
  policy      = jsonencode(var.POLICY)
}
