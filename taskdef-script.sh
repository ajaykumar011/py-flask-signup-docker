#!/bin/bash
SERVICE_NAME="flask-signup-service"
CLUSTER_NAME="ecs-cluster-demo"
IMAGE_VERSION="v_"${BUILD_NUMBER}
TASK_FAMILY="flask-signup"

# Create a new task definition for this build
sed -e "s;%BUILD_NUMBER%;${BUILD_NUMBER};g" flask-signup.json > flask-signup-v_${BUILD_NUMBER}.json
aws ecs register-task-definition --family flask-signup --cli-input-json file://flask-signup-v_${BUILD_NUMBER}.json

# Update the service with the new task definition and desired count
TASK_REVISION=`aws ecs describe-task-definition --task-definition flask-signup | egrep "revision" | tr "/" " " | awk '{print $2}' | sed 's/"$//' | sed 's/,$//'`
DESIRED_COUNT=`aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME} | grep -m 1 "desiredCount" | tr "/" " " | awk '{print $2}' | sed 's/,$//'`
if [ "${DESIRED_COUNT}" == "0" ]; then
    DESIRED_COUNT="1"
fi

echo $DESIRED_COUNT
echo $TASK_REVISION

aws ecs update-service --cluster ecs-cluster-demo --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT}

