data "aws_iam_policy_document" "this" {
  version = var.VERSION
  dynamic "statement" {
    for_each = var.STATEMENTS
    content {
      actions      = statement.value.actions
      resources    = statement.value.resources
      dynamic "condition" {
        for_each = flatten(tolist(lookup(statement.value, "condition", [])))
        content {
          test                = lookup(condition.value, "test", "")
          variable            = lookup(condition.value, "variable", "")
          values              = lookup(condition.value, "values", [])
        }
      }
    }
  }
}
resource "aws_iam_policy" "this" {
  name        = var.NAME
  path        = var.PATH
  description = var.DESCRIPTION
  policy      = var.POLICY_JSON ? var.POLICY : data.aws_iam_policy_document.this.json
}
