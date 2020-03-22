SHELL = /bin/bash
AWS_REGION ?= eu-central-1
AWS_PROFILE ?= default
STACK_NAME_DEV ?= dev

.PHONY = deploy deployDEV destroyDEV _deployDevVPC _destroyDevVPC _deployDevDynamoDBTable _destroyDevDynamoDBTable _deployClimateMicroservice _destroyClimateMicroservice _deployPipeline _destroyPipeline _deployALB

help:
	@echo "Usage: "
	@echo -e "\n  ==================DEV-ENVIRONMENT=================="
	@echo -e "\n  To deploy the infrastructure on dev-env:"
	@echo "    make deployDEV"
	@echo -e "\n  To destroy the created infrastructure on dev-env:"
	@echo "    make destroyDEV"
	@echo -e "\n  ==================PROD-ENVIRONMENT=================="
	@echo -e "\n  To deploy the infrastructure on prod-env:"
	@echo "    ...currently not available..."
	@echo -e "\n  To destroy the created infrastructure on prod-env:"
	@echo "    ...currently not available..."
	@echo -e "\n  ===================================================="

deployDEV: _deployDevVPC _deployDevECSCluster _deployDevDynamoDBTable _deployClimateMicroservice

destroyDEV: _destroyDevVPC _destroyDevECSCluster _destroyDevDynamoDBTable _destroyClimateMicroservice

deployBasePipelineOnDev: _deployBasePipelineOnDev

destroyBasePipelineOnDev: _destroyBasePipelineOnDev

deployClimatePipelineOnDev: _deployClimatePipelineOnDev

deployALB: _deployALB


_deployALB:
	@echo "Creating the ALB..."
	@aws cloudformation create-stack --stack-name ${STACK_NAME_DEV}-smartoffice-alb --template-body file://elb/template.yaml --parameters file://elb/dev.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME_DEV}-smartoffice-alb --region ${AWS_REGION} --profile ${AWS_PROFILE}

# ####################################################################################################################################
# CI / CD
# ####################################################################################################################################

_deployBasePipelineOnDev:
	@echo "Creating the Dev-Pipeline..."
	@aws cloudformation create-stack --stack-name ${STACK_NAME_DEV}-cf-base-pipeline --template-body file://cicd/base/template.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME_DEV}-cf-base-pipeline --region ${AWS_REGION} --profile ${AWS_PROFILE}

_destroyBasePipelineOnDev:
	@echo "Destroying the VPC-DEV stack..."
	@aws s3 rm s3://codepipeline-cf-source/CfPipeline --recursive
	@aws cloudformation delete-stack --stack-name ${STACK_NAME_DEV}-cf-base-pipeline --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been destroyed... this can take some minutes"
	@aws cloudformation wait stack-delete-complete --stack-name ${STACK_NAME_DEV}-cf-base-pipeline --region ${AWS_REGION} --profile ${AWS_PROFILE}


_deployClimatePipelineOnDev:
	@echo "Creating the Dev-Pipeline..."
	@aws cloudformation create-stack --stack-name ${STACK_NAME_DEV}-climate-infra-pipeline --template-body file://cicd/climate/template.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

# ####################################################################################################################################
# D E V - S T A G E
# ####################################################################################################################################

# ######################
# VPC-Stack-DEV
# ######################
_deployDevVPC:
	@echo "Creating the VPC-DEV stack..."
	@aws cloudformation create-stack --stack-name ${STACK_NAME_DEV}-vpc --template-body file://vpc/template.yaml --parameters file://vpc/dev.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME_DEV}-vpc --region ${AWS_REGION} --profile ${AWS_PROFILE}
	@echo "VPC-DEV stack successful created!"

_destroyDevVPC:
	@echo "Destroying the VPC-DEV stack..."
	@aws cloudformation delete-stack --stack-name ${STACK_NAME_DEV}-vpc --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been destroyed... this can take some minutes"
	@aws cloudformation wait stack-delete-complete --stack-name ${STACK_NAME_DEV}-vpc --region ${AWS_REGION} --profile ${AWS_PROFILE}

# ######################
# ECS-Cluster-Stack-DEV
# ######################
_deployDevECSCluster:
	@echo "Creating the ECS-DEV-CLUSTER stack ..."
	@aws cloudformation create-stack --stack-name $(STACK_NAME_DEV)-ecs-cluster --template-body file://ecs-cluster/template.yaml --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created..."
	@aws cloudformation wait stack-create-complete --stack-name $(STACK_NAME_DEV)-ecs-cluster --region ${AWS_REGION} --profile ${AWS_PROFILE}
	@echo "ECS-DEV-Cluster stack successful created!"

_destroyDevECSCluster:
	@echo "Destroying the ECS-DEV cluster ..."
	@aws cloudformation delete-stack --stack-name ${STACK_NAME_DEV}-ecs-cluster --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been destroyed... this can take some minutes"
	@aws cloudformation wait stack-delete-complete --stack-name ${STACK_NAME_DEV}-ecs-cluster --region ${AWS_REGION} --profile ${AWS_PROFILE}

# ######################
# DDB-Table-Stack-DEV
# ######################
_deployDevDynamoDBTable:
	@echo "Creating the DynamoDB-DEV-Table stack..."
	@aws cloudformation create-stack --stack-name $(STACK_NAME_DEV)-ddb --template-body file://ddb/template.yaml --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created..."
	@aws cloudformation wait stack-create-complete --stack-name $(STACK_NAME_DEV)-ddb --region ${AWS_REGION} --profile ${AWS_PROFILE}
	@echo "DynamoDB-DEV-Table stack successful created!"	

_destroyDevDynamoDBTable:
	@echo "Destroying the DynamoDB-DEV table ..."
	@aws cloudformation delete-stack --stack-name $(STACK_NAME_DEV)-ddb --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been destroyed... this can take some minutes"
	@aws cloudformation wait stack-delete-complete --stack-name $(STACK_NAME_DEV)-ddb --region ${AWS_REGION} --profile ${AWS_PROFILE}	

# ######################
# Climate-Microservice-Stack-DEV
# ######################
_deployClimateMicroservice:
	@echo "Creating the climate-microservice stack..."
	@aws cloudformation create-stack --stack-name $(STACK_NAME_DEV)-climate-microservice --template-body file://microservices/template.yaml --cli-input-json file://microservices/climate/dev.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created..."
	@aws cloudformation wait stack-create-complete --stack-name $(STACK_NAME_DEV)-climate-microservice --region ${AWS_REGION} --profile ${AWS_PROFILE}
	@echo "climate-microservice stack successful created!"	

_destroyClimateMicroservice:
	@echo "Destroying the climate-microservice stack ..."
	@aws cloudformation delete-stack --stack-name $(STACK_NAME_DEV)-climate-microservice --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been destroyed... this can take some minutes"
	@aws cloudformation wait stack-delete-complete --stack-name $(STACK_NAME_DEV)-climate-microservice --region ${AWS_REGION} --profile ${AWS_PROFILE}	


# ####################################################################################################################################
# P R O D - S T A G E
# ####################################################################################################################################
