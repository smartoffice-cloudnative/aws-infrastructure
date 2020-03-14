SHELL = /bin/bash
AWS_REGION ?= eu-central-1
AWS_PROFILE ?= default
STACK_NAME_DEV ?= dev

.PHONY = deploy deployDEV destory _deployDevVPC _destroyDevVPC

help:
	@echo "Usage: "
	@echo -e "\n  To deploy the infrastructure on dev-env:"
	@echo "    make deployDEV"
	@echo -e "\n  To destroy the created infrastructure on dev-env:"
	@echo "    make destoryDEV"

deployDEV:	_deployDevVPC

destoryDEV: _destroyDevVPC

_deployDevVPC:
	@echo "Creating the VPC-DEV stack..."
	@aws cloudformation create-stack --stack-name ${STACK_NAME_DEV} --template-body file://vpc/template.yaml --cli-input-json file://vpc/DEV.json --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created..."
	@aws cloudformation wait stack-create-complete --stack-name ${STACK_NAME_DEV} --region ${AWS_REGION} --profile ${AWS_PROFILE}

_destroyDevVPC:
	@echo "Destorying the VPC-DEV stack..."
	@aws cloudformation delete-stack --stack-name ${STACK_NAME_DEV} --region ${AWS_REGION} --profile ${AWS_PROFILE}

	@echo "Waiting till all resources have been created..."
	@aws cloudformation wait stack-delete-complete --stack-name ${STACK_NAME_DEV} --region ${AWS_REGION} --profile ${AWS_PROFILE}

