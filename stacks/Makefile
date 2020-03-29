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
	@echo -e "\n To deploy the cross-account base-infrastructure-pipeline:"
	@echo "    make deployBasePipeline"
	@echo -e "\n  To destroy all Stacks in all accounts:"
	@echo "    make destroyBasePipeline"

deployBasePipeline: _deployPreRequirements _deployProdRoleForCiCdCrossAccountAccess _deployBasePipeline
destroyBasePipeline: _destroyProdStacks _destroyDevOpsStacks

# ####################################################################################################################################
# CI / CD - BASE PIPELINE FOR CLOUDFORMATION BASE-INFRASTRUCTURE
# ####################################################################################################################################

# -----------
# CREATE:
# -----------
_deployPreRequirements:
	@echo "Creating the base-preReq Stack..."
	@aws cloudformation create-stack --stack-name base-preReq-${STACK_NAME_DEVOPS_PREFIX} --template-body file://cicd/base/devops/pre-req.yaml \
		--parameters file://cicd/base/devops/pre-req-vars.json --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name base-preReq-${STACK_NAME_DEVOPS_PREFIX} --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}
	@echo "successful created!"

_deployProdRoleForCiCdCrossAccountAccess:
	@echo -e "\n Creating the prodRoleCrossAccountCiCAccess Stack in Prod-Stage..."
	@aws cloudformation create-stack --stack-name base-prodRoleCrossAccountCiCAccess-${STACK_NAME_PROD_PREFIX} --template-body file://cicd/base/prod/template.yaml --capabilities CAPABILITY_NAMED_IAM \
		--parameters ParameterKey="S3Bucket",ParameterValue="artifactbucket-smartoffice-cf-sourcecode" \
		  	ParameterKey="DevOpsAccount",ParameterValue="147376585776" \
		  	ParameterKey="CMKArn",ParameterValue=$(shell aws cloudformation describe-stacks --stack-name base-preReq-devops | jq '.Stacks[] | .Outputs[] | select(.OutputValue | contains("kms")) | .OutputValue') \
		--profile ${AWS_PROD_PROFILE} --region ${AWS_REGION}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name base-prodRoleCrossAccountCiCAccess-${STACK_NAME_PROD_PREFIX} --profile ${AWS_PROD_PROFILE} --region ${AWS_REGION}
	@echo "successful created!"

_deployBasePipeline:
	@echo -e "\n Creating the base-cfPipeline-dev Stack..."
	@aws cloudformation create-stack --stack-name base-cfPipeline-${STACK_NAME_DEVOPS_PREFIX} --template-body file://cicd/base/devops/template.yaml \
		--parameters ParameterKey="ProdAccount",ParameterValue="496106771575" \
			ParameterKey="gitHubOAuthToken",ParameterValue=${GITHUB_TOKEN} \
			ParameterKey="PreReqStack",ParameterValue="base-preReq-devops" \
		 --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION} --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete --stack-name base-cfPipeline-${STACK_NAME_DEVOPS_PREFIX} --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}
	@echo "successful created!"

# -----------
# DESTROY:
# -----------
_destroyProdStacks:
	@echo "====Destroying the Prod-Stacks===="
	@echo -e "\n Start deletion of Prod-ELB"
	@aws cloudformation delete-stack --stack-name base-elb-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-elb-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-ECSCluster"
	@aws cloudformation delete-stack --stack-name base-ecsCluster-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-ecsCluster-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-VPC"
	@aws cloudformation delete-stack --stack-name base-vpc-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-vpc-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-ProdRoleCrossAccountCiCAccess"
	@aws cloudformation delete-stack --stack-name base-prodRoleCrossAccountCiCAccess-prod --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-prodRoleCrossAccountCiCAccess-prod --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "Deletion successful finished!"

_destroyDevOpsStacks:
	@echo -e "\n ====Destroying the DevOps-Stacks===="
	@echo "Start deletion of cfPipeline"
	@aws cloudformation delete-stack --stack-name base-cfPipeline-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-cfPipeline-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "Deletion successful finished!"

	@echo -e "\n Start deletion PreReq-Stack"
	@aws s3 rm s3://artifactbucket-smartoffice-cf-sourcecode --recursive
	@aws cloudformation delete-stack --stack-name base-preReq-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-preReq-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "Deletion successful finished!"

# ####################################################################################################################################
# CI / CD - PIPELINE FOR CLIMATE-MICROSERVICE INFRASTRUCTURE
# ####################################################################################################################################

# -----------
# CREATE:
# -----------
# todo...

# -----------
# DESTROY:
# -----------
# todo...

