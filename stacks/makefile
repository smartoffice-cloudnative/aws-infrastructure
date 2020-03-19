SHELL = /bin/bash
AWS_REGION ?= eu-central-1
AWS_PROFILE ?= default
STACK_NAME_DEV ?= dev

.PHONY = deploy deployDEV destroyDEV _deployDevVPC _destroyDevVPC _deployDevDynamoDBTable _destroyDevDynamoDBTable _deployClimateMicroservice _destroyClimateMicroservice

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

# deployDEV: _deployDevVPC _deployDevECSCluster _deployDevDynamoDBTable _deployClimateMicroservice
deployDEV: _deployDevVPC

# destroyDEV: _destroyDevVPC _destroyDevECSCluster _destroyDevDynamoDBTable _destroyClimateMicroservice
destroyDEV: _destroyDevVPC


# ####################################################################################################################################
# D E V - S T A G E
# ####################################################################################################################################

# ######################
# VPC-Stack-DEV
# ######################
_deployDevVPC:
	@echo "Creating the VPC-DEV stack..."
	@aws cloudformation create-stack --stack-name ${STACK_NAME_DEV}-vpc --template-body file://vpc/template.yaml --parameters file://vpc/prod.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

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
