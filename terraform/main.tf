module "VPC" {
    source                      = "./modules/VPC/"
    AVAILABILITY_ZONES          = data.aws_availability_zones.available.names
    COMMON_TAGS                 = local.common_tags
    TAGS                        = var.TAGS
    NAME                        = var.NAME
    AZS_COUNT                   = var.AZS_COUNT
    VPC_CIDR                    = var.VPC_CIDR
    PRIVATE_SUBNETS             = var.PRIVATE_SUBNETS
    PUBLIC_SUBNETS              = var.PUBLIC_SUBNETS
}

module "SecurityGroup" {
  source              = "./modules/SecurityGroup/"
  COMMON_TAGS         = local.common_tags
  TAGS                = var.TAGS
  SG_NAME             = "${var.NAME}-SecurityGroup"
  SG_DESCRIPTION      = "SecurityGroup for a AutoScalingGroup"
  VPC_ID              = module.VPC.VPC_ID
  SG_INGRESS = [
    {
      sg_ingress_from_port       = 80
      sg_ingress_to_port         = 80
      sg_ingress_protocol        = "tcp"
      sg_ingress_description     = "Allow HTTP traffic"
      sg_ingress_cidr_blocks     = ["0.0.0.0/0"]
    },
    {
      sg_ingress_from_port       = 22
      sg_ingress_to_port         = 22
      sg_ingress_protocol        = "tcp"
      sg_ingress_description     = "Allow SSH traffic"
      sg_ingress_cidr_blocks     = ["0.0.0.0/0"]
    }
  ]
}


module "IAM_Role" {
  source                  = "./modules/IAM_Role/"
  COMMON_TAGS             = local.common_tags
  TAGS                    = var.TAGS
  NAME                    = "${var.NAME}-ec2Role"
  STATEMENTS              = [
                              {
                              effect = "Allow"
                              actions = ["sts:AssumeRole"]
                              principals = {
                                type = "Service"
                                identifiers = ["ec2.amazonaws.com"]
                                }
                              }
                            ]
  CREATE_INSTANCE_PROFILE = true
  POLICIES_ARN            = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess", "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"]
  PATH                    = "/"
}

module "IAM_Policy_Pipeline" {
  source            = "./modules/IAM_Policy/"
  NAME              = "${var.NAME}-pipelinePolicy"
  DESCRIPTION       = "Pipeline role policy for S3"
  POLICY            = {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPipelineBucket",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:AbortMultipartUpload",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:GetObjectVersion",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${module.S3.S3_BUCKET_NAME}/*",
                "arn:aws:s3:::${module.S3.S3_BUCKET_NAME}"
            ]
        },
        {
            "Sid": "AllowCodedeployToCreateDeployment",
            "Effect": "Allow",
            "Action": [
              "codedeploy:CreateDeployment",
              "codedeploy:GetApplicationRevision",
              "codedeploy:GetDeployment",
              "codedeploy:GetDeploymentConfig",
              "codedeploy:RegisterApplicationRevision"
            ]
            "Resource": "*"
        }        
    ]
  }
}

module "IAM_Role_Pipeline" {
  source                  = "./modules/IAM_Role/"
  COMMON_TAGS             = local.common_tags
  TAGS                    = var.TAGS
  NAME                    = "${var.NAME}-pipelineRole"
  STATEMENTS              = [
                              {
                              effect = "Allow"
                              actions = ["sts:AssumeRole"]
                              principals = {
                                type = "Service"
                                identifiers = ["codepipeline.amazonaws.com", "codedeploy.amazonaws.com"]
                                }
                              }
                            ]
  CREATE_INSTANCE_PROFILE = false
  POLICIES_ARN            = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy", "arn:aws:iam::aws:policy/AmazonEC2FullAccess", "${module.IAM_Policy_Pipeline.IAM_POLICY_ARN}"]
  PATH                    = "/"
}


module "AutoScaling" {
  source                            = "./modules/AutoScaling/"
  COMMON_TAGS                       = local.common_tags
  TAGS                              = var.TAGS
  INSTANCE_TAGS                     = {}
        
###################
### Launch Template
###################

  TEMPLATE_NAME                     = "${var.NAME}-launchTemplate"
  ASG_IAM_INSTANCE_PROFILE_NAME     = module.IAM_Role.IAM_ROLE_NAME
  ASG_SECURITY_GROUP_IDS            = [module.SecurityGroup.SECURITY_GROUP_ID]
  IMAGE_ID                          = "ami-0f599bbc07afc299a"
  INSTANCE_TYPE                     = "t2.micro"
  ASG_EBS_BLOCK_DEVICE              = [{
                                        # Root volume
                                        device_name = "/dev/xvda"
                                        no_device   = 0
                                        ebs = {
                                          delete_on_termination = true
                                          encrypted             = true
                                          volume_size           = 20
                                          volume_type           = "gp2"
                                        }
                                      }, 
                                      {
                                        device_name = "/dev/sdb"
                                        no_device   = 1
                                        ebs = {
                                          delete_on_termination = true
                                          encrypted             = true
                                          volume_size           = 30
                                          volume_type           = "gp2"
                                        }
                                      }
                                      ]

######################
### Auto scaling group
######################

  ASG_NAME                              = "${var.NAME}-AutoScaling"
  ASG_SUBNET_IDS                        = module.VPC.PRIVATE_SUBNET_IDS
  ASG_MIN_SIZE                          = 1
  ASG_MAX_SIZE                          = 1
  ASG_DESIRED_CAPACITY                  = 1
  ASG_TARGET_GROUP_ARNS                 = [module.ALB.ALB_TARGET_GROUPS_ARN.0]
}

module "AutoScaling1" {
  source                            = "./modules/AutoScaling/"
  COMMON_TAGS                       = local.common_tags
  TAGS                              = var.TAGS
  INSTANCE_TAGS                     = {}
        
###################
### Launch Template
###################

  TEMPLATE_NAME                     = "${var.NAME}-launchTemplate1"
  ASG_IAM_INSTANCE_PROFILE_NAME     = module.IAM_Role.IAM_ROLE_NAME
  ASG_SECURITY_GROUP_IDS            = [module.SecurityGroup.SECURITY_GROUP_ID]
  IMAGE_ID                          = "ami-0f599bbc07afc299a"
  INSTANCE_TYPE                     = "t2.micro"
  ASG_EBS_BLOCK_DEVICE              = [{
                                        # Root volume
                                        device_name = "/dev/xvda"
                                        no_device   = 0
                                        ebs = {
                                          delete_on_termination = true
                                          encrypted             = true
                                          volume_size           = 20
                                          volume_type           = "gp2"
                                        }
                                      },
                                      {
                                        device_name = "/dev/sdb"
                                        no_device   = 1
                                        ebs = {
                                          delete_on_termination = true
                                          encrypted             = true
                                          volume_size           = 30
                                          volume_type           = "gp2"
                                        }
                                      }
                                      ]

######################
### Auto scaling group
######################

  ASG_NAME                              = "${var.NAME}-AutoScaling1"
  ASG_SUBNET_IDS                        = module.VPC.PRIVATE_SUBNET_IDS
  ASG_MIN_SIZE                          = 1
  ASG_MAX_SIZE                          = 1
  ASG_DESIRED_CAPACITY                  = 1
  ASG_TARGET_GROUP_ARNS                 = [module.ALB.ALB_TARGET_GROUPS_ARN.1]
}


###########################
### ApplicationLoadBalancer
###########################

module "ALB" {
  source      = "./modules/ALB/"
  COMMON_TAGS = local.common_tags
  TAGS        = var.TAGS
  ###############
  ### Application LoadBalancer
  ###############
  ALB_NAME               = "${var.NAME}-LB"
  ALB_SUBNET_IDS         = module.VPC.PUBLIC_SUBNET_IDS
  ALB_SECURITY_GROUP_IDS = [module.SecurityGroup.SECURITY_GROUP_ID]
  ALB_VPC_ID             = module.VPC.VPC_ID
  ALB_TARGET_GROUPS      =[{
              backend_protocol      = "HTTP"
              name                  = "${var.NAME}-App1"
              backend_port          = 80
              target_type           = "instance"
              health_check          = {
                  enabled             = "true"
                  interval            = "30"
                  path                = "/"
                  healthy_threshold   = "3"
                  unhealthy_threshold = "3"
        }
        },
        {
                backend_protocol      = "HTTP"
                name                  = "${var.NAME}-App2"
                backend_port          = 80
                target_type           = "instance"
                health_check          = {
                    enabled             = "true"
                    interval            = "30"
                    path                = "/"
                    healthy_threshold   = "3"
                    unhealthy_threshold = "3"
                }
          }  
  ]
  ALB_HTTP_TCP_LISTENERS = [{
                              port = 80
                              protocol = "HTTP"
                            }]
  }

module "S3" {
    source            = "./modules/S3/"
    COMMON_TAGS       = local.common_tags
    TAGS              = var.TAGS
    BUCKET_NAME       = "${var.NAME}-${data.aws_caller_identity.current.account_id}"
}

module "CodePipeline" {
  source      = "./modules/CodePipeline/"
  TAGS        = var.TAGS
  COMMON_TAGS = local.common_tags
  RESOURCE    = "EC2"
  CODE_PIPELINE_NAME= "${var.NAME}-Pipeline"
  CODE_PIPELINE_ROLE= module.IAM_Role_Pipeline.IAM_ROLE_ARN
  ARTIFECT_BUCKET_NAME= module.S3.S3_BUCKET_NAME
  SOURCE_ACTION= [
    {
      name= "Source"
      category= "Source"
      owner= "ThirdParty"
      provider= "GitHub"
      version= 1
      output_artifacts= [ "SourceArtifact" ]
      run_order= 1
      configuration= {
        Owner= "sikandarqaisar"
        Repo= "task"
        PollForSourceChanges= true
        Branch= "main"
        OAuthToken= ""
      }
    }
  ]
  CODEDEPLOY_APPLICATION= [
    {
      compute_platform= "Server"
      name= "ec2Deploy"
    }
  ]
  DEPLOYMENT_CONFIG= [
    {
      deployment_config_name= "ec22Deploy"
      minimum_healthy_hosts= [
        {
          type= "HOST_COUNT"
          value= 0
        }
      ]
    }       
  ]
  DEPLOYMENT_GROUP= [
    {
      app_name= "ec2Deploy"
      deployment_group_name= "ec2Deploy"
      service_role_arn= module.IAM_Role_Pipeline.IAM_ROLE_ARN
      deployment_config_name= "CodeDeployDefault.AllAtOnce"
      autoscaling_groups = [module.AutoScaling1.AUTOSCALING_GROUP_NAME]
      auto_rollback_configuration= [
          {
              enabled= false
              events= ["DEPLOYMENT_FAILURE"]
            }                    
      ]
    }   
  ]
  DEPLOY_APPROVAL= []
  DEPLOY_ACTION= [
    {
      name= "Deploy"
      action= {
        name= "Deploy"
        category= "Deploy"
        owner= "AWS"
        provider= "CodeDeploy"
        input_artifacts= [ "SourceArtifact" ]
        version= 1
        region= "us-east-2"
        configuration= {
          ApplicationName= "ec2Deploy"
          DeploymentGroupName= "ec2Deploy"
          ClusterName= null
          ServiceName= null
          FileName= null
        }
      }
    }
  ]
}
output "codedeploy"{
  value = module.CodePipeline.CODE_DEPLOY_DEPLOYMENT_GROUP_ARN
}