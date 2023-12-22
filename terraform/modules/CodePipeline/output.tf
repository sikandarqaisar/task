output "CODE_DEPLOY_APPLICATION_ID" {
  value = toset([
    for App in aws_codedeploy_app.App : App.id
  ])
}

output "CODE_DEPLOY_APPLICATION_ARN" {
  value = toset([
    for App in aws_codedeploy_app.App : App.arn
  ])
}

output "CODE_DEPLOY_DEPLOYMENT_CONFIG_ID" {
  value = toset([
    for deployment_config in aws_codedeploy_deployment_config.deployment_config : deployment_config.deployment_config_id
  ])
}

output "CODE_DEPLOY_DEPLOYMENT_GROUP_ARN" {
  value = toset([
    for deployment_group in aws_codedeploy_deployment_group.deployment_group : deployment_group.arn
  ])
}

output "CODE_DEPLOY_DEPLOYMENT_GROUP_ID" {
  value = toset([
    for deployment_group in aws_codedeploy_deployment_group.deployment_group : deployment_group.deployment_group_id
  ])
}

output "CODE_PIPELINE_ID" {
  value       = aws_codepipeline.pipeline.id
}

output "CODE_PIPELINE_ARN" {
  value       = aws_codepipeline.pipeline.arn
}