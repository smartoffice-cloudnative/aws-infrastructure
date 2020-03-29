SHELL = /bin/bash
AWS_REGION ?= eu-central-1
AWS_DEVOPS_PROFILE ?= default
AWS_PROD_PROFILE ?= michi.prod

STACK_NAME_DEV_PREFIX ?= dev
STACK_NAME_PROD_PREFIX ?= prod
STACK_NAME_DEVOPS_PREFIX ?= devops

.PHONY = deployBasePipeline _deployBasePipeline destroyBasePipeline _destroyBasePipeline _deployProdRoleForCiCdCrossAccountAccess

help:
	@echo "Usage: "
	@echo -e "\n  To deploy the cross-account base-infrastructure-pipeline:"
	@echo "    make deployBasePipeline"
	@echo -e "\n  To destroy the cross-account base-infrastructure-pipeline:"
	@echo "    make destroyBasePipeline"

deployBasePipeline: _deployBasePipeline
destroyBasePipeline: _destroyBasePipeline

# ####################################################################################################################################
# CI / CD - BASE PIPELINE FOR CLOUDFORMATION INFRASTRUCTURE
# ####################################################################################################################################

_deployPreRequirements:
	@echo "Creating the base-preReq..."
	@aws cloudformation create-stack --stack-name base-preReq-${STACK_NAME_DEVOPS_PREFIX} --template-body file://cicd/base/devops/pre-req.yaml \
		--parameters file://cicd/base/devops/pre-req-vars.json --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name base-preReq-${STACK_NAME_DEVOPS_PREFIX} --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}

_deployProdRoleForCiCdCrossAccountAccess:
	@echo "Creating the prodRoleCrossAccountCiCAccess..."
	@aws cloudformation create-stack --stack-name base-prodRoleCrossAccountCiCAccess-${STACK_NAME_PROD_PREFIX} --template-body file://cicd/base/prod/template.yaml --parameters file://cicd/base/prod/tmpl-vars.json --profile ${AWS_PROD_PROFILE} --region ${AWS_REGION} --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name base-prodRoleCrossAccountCiCAccess-${STACK_NAME_PROD_PREFIX} --profile ${AWS_PROD_PROFILE} --region ${AWS_REGION}

_deployBasePipeline:
	@echo "Creating the base-cfPipeline-dev..."
	@aws cloudformation create-stack --stack-name base-cfPipeline-${STACK_NAME_DEVOPS_PREFIX} --template-body file://cicd/base/devops/template.yaml --parameters file://cicd/base/devops/tmpl-vars.json --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION} --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name base-cfPipeline-${STACK_NAME_DEVOPS_PREFIX} --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}


_destroyBasePipeline:
	@echo "Destroying the VPC-DEV stack..."
	@aws s3 rm s3://artifactBucket/CfPipeline --recursive
	@aws cloudformation delete-stack --stack-name base-cfPipeline-${STACK_NAME_DEV_PREFIX} --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}

	@echo "Waiting till all resources have been destroyed... this can take some minutes"
	@aws cloudformation wait stack-delete-complete --stack-name base-cfPipeline-${STACK_NAME_DEV_PREFIX} --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}







# ####
# old one => template.json
# ###
_oldOne:
	@echo "Creating the base-cfPipeline-dev..."
	@aws cloudformation create-stack --stack-name cfPipeline-${STACK_NAME_DEVOPS_PREFIX} --template-body file://cicd/base/template.json --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION} --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name cfPipeline-${STACK_NAME_DEVOPS_PREFIX} --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}
