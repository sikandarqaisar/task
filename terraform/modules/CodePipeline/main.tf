
##########################################################
############# Code Deploy application and Deployment Group
##########################################################

resource "aws_codedeploy_app" "App" {
  count = length(var.CODEDEPLOY_APPLICATION) > 0 ? length(var.CODEDEPLOY_APPLICATION) : 0

  compute_platform = var.CODEDEPLOY_APPLICATION[count.index].compute_platform
  name             = var.CODEDEPLOY_APPLICATION[count.index].name

  tags = merge(
    var.COMMON_TAGS,
    var.TAGS
  )
}

resource "aws_codedeploy_deployment_config" "deployment_config" {
  count = length(var.DEPLOYMENT_CONFIG) > 0 ? length(var.DEPLOYMENT_CONFIG) : 0

  deployment_config_name = var.DEPLOYMENT_CONFIG[count.index].deployment_config_name

  dynamic "minimum_healthy_hosts" {
    for_each = var.DEPLOYMENT_CONFIG[count.index].minimum_healthy_hosts
    content {
      type  = lookup(minimum_healthy_hosts.value, "type", "")
      value = lookup(minimum_healthy_hosts.value, "value", "")
    }
  }
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  count = length(var.DEPLOYMENT_GROUP) > 0 ? length(var.DEPLOYMENT_GROUP) : 0

  depends_on = [
    aws_codedeploy_app.App
  ]
  app_name               = var.DEPLOYMENT_GROUP[count.index].app_name
  deployment_group_name  = var.DEPLOYMENT_GROUP[count.index].deployment_group_name
  service_role_arn       = var.DEPLOYMENT_GROUP[count.index].service_role_arn
  deployment_config_name = var.DEPLOYMENT_GROUP[count.index].deployment_config_name
  autoscaling_groups     = var.DEPLOYMENT_GROUP[count.index].autoscaling_groups

  dynamic "auto_rollback_configuration" {
    for_each = var.DEPLOYMENT_GROUP[count.index].auto_rollback_configuration

    content {
      enabled = lookup(auto_rollback_configuration.value, "enabled", true)
      events  = lookup(auto_rollback_configuration.value, "events", [])
    }
  }
  tags = merge(
    var.COMMON_TAGS,
    var.TAGS
  )

}

#########################################
############## Code PipeLine       
########################################

resource "aws_codepipeline" "pipeline" {
  name     = var.CODE_PIPELINE_NAME
  role_arn = var.CODE_PIPELINE_ROLE

  tags = merge(
    var.COMMON_TAGS,
    var.TAGS
  )

  artifact_store {
    location = var.ARTIFECT_BUCKET_NAME
    type     = "S3"
  }

  stage {
    name = "Source"
    dynamic "action" {
      for_each = var.SOURCE_ACTION
      content {
        name             = lookup(action.value, "name", "")
        category         = lookup(action.value, "category", "")
        owner            = lookup(action.value, "owner", "")
        provider         = lookup(action.value, "provider", "")
        version          = lookup(action.value, "version", "")
        output_artifacts = lookup(action.value, "output_artifacts", [])
        run_order        = lookup(action.value, "run_order", "")
        configuration = {
          Owner                = action.value.configuration["Owner"]
          Repo                 = action.value.configuration["Repo"]
          PollForSourceChanges = action.value.configuration["PollForSourceChanges"]
          Branch               = action.value.configuration["Branch"]
          OAuthToken           = action.value.configuration["OAuthToken"]
        }
      }
    }

  }

  dynamic "stage" {
    for_each = var.DEPLOY_APPROVAL
    content {
      name = lookup(stage.value, "name", "")

      dynamic "action" {
        for_each = stage.value["action"]
        content {
          name     = lookup(action.value, "name", "")
          category = lookup(action.value, "category", "")
          owner    = lookup(action.value, "owner", "")
          provider = lookup(action.value, "provider", "")
          version  = lookup(action.value, "version", null)
        }
      }
    }
  }


  dynamic "stage" {
    for_each = var.DEPLOY_ACTION
    content {
      name = lookup(stage.value, "name", "")

      dynamic "action" {
        for_each = [stage.value["action"]]
        content {
          name            = lookup(action.value, "name", "")
          category        = lookup(action.value, "category", "")
          owner           = lookup(action.value, "owner", "")
          provider        = lookup(action.value, "provider", "")
          input_artifacts = lookup(action.value, "input_artifacts", [])
          version         = lookup(action.value, "version", null)
          region          = lookup(action.value, "region", "")
          configuration = {
            "ApplicationName"                = action.value.configuration["ApplicationName"]
            "DeploymentGroupName"            = action.value.configuration["DeploymentGroupName"]
          }
        }
      }
    }
  }

}

