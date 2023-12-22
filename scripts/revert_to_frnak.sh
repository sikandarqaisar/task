#!/bin/bash
aws ssm send-command \
    --document-name "AWS-RunShellScript" \
    --comment "Updateing file data" \
    --targets "Key=tag:Name,Values=task-launchTemplate1-Instance" \
    --parameters commands='echo \<h3\> Hi\, I am Frank \</h3\> > /usr/share/nginx/html/index.html' \
    --output text  \
    --region us-east-2