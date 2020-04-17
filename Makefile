SHELL = /bin/bash
AWS_REGION ?= eu-central-1
AWS_DEVOPS_PROFILE ?= default
AWS_PROD_PROFILE ?= michi.prod

STACK_NAME_DEV_PREFIX ?= dev
STACK_NAME_PROD_PREFIX ?= prod
STACK_NAME_DEVOPS_PREFIX ?= devops

help:
	@echo "Usage: "
	@echo -e "\nTo deploy the pipeline for the base-infrastructure:"
	@echo "    1.) 'make deployPipelineForBaseInfrastructure'"
	@echo "    2.) 'make deployPipelineForClimateInfrastructure'"
	@echo "    3.) 'make deployPipelineForClimateMicroservice'"
	@echo -e "\nTo destroy all Stacks in all accounts:"
	@echo "    make destroyAllStacksInAllStages"

deployPipelineForBaseInfrastructure: _deployPreRequirements _deployCfBasePipelineRoleForCrossAccountAccess _deployBasePipelineRole  _putKmsPolicy _deployBasePipeline
destroyPipelineForBaseInfrastructure: _destroyProdStacks _destroyDevOpsStacks

# ####################################################################################################################################
# CI / CD - BASE PIPELINE FOR CLOUDFORMATION BASE-INFRASTRUCTURE
# ####################################################################################################################################

# -------------------------------
# CREATE BASE-INFRASTRUCTURE:
# -------------------------------
_deployPreRequirements:
	@echo "Creating the base-preReq Stack..."
	@aws cloudformation create-stack \
		--stack-name base-preReq-devops \
		--template-body file://stacks/cicd/base-infrastructure/devops/prereq/template.yaml \
		--parameters file://stacks/cicd/base-infrastructure/devops/prereq/vars.json \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name base-preReq-devops \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}
	@echo "successful created!"

_deployCfBasePipelineRoleForCrossAccountAccess:
	@echo -e "\n Creating the cfBasePipeline-CrossAcount-Role Stack in Prod-Stage..."
	@aws cloudformation create-stack \
		--stack-name cfBasePipeline-CrossAcount-Role-prod \
		--template-body file://stacks/cicd/base-infrastructure/prod/basepipeline-prod-role.yaml \
		--parameters \
			ParameterKey="S3Bucket",ParameterValue="artifactbucket-smartoffice-cf-sourcecode" \
		  	ParameterKey="DevOpsAccount",ParameterValue="147376585776" \
		  	ParameterKey="CMKArn",ParameterValue=$(shell $(call getOutputValueOfStack,base-preReq-devops,${AWS_DEVOPS_PROFILE},kms)) \
		--capabilities CAPABILITY_NAMED_IAM \
		--profile ${AWS_PROD_PROFILE} \
		--region ${AWS_REGION}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name cfBasePipeline-CrossAcount-Role-prod \
		--profile ${AWS_PROD_PROFILE} \
		--region ${AWS_REGION}
	@echo "successful created!"

_deployBasePipelineRole:
	@echo "Creating the CodePipeline-Role Stack..."
	@aws cloudformation create-stack \
		--stack-name cfBasePipeline-Role-devops \
		--template-body file://stacks/cicd/base-infrastructure/devops/basepipeline-role/template.yaml \
		--parameters \
			ParameterKey="ProdAccount",ParameterValue="496106771575" \
			ParameterKey="PreReqStack",ParameterValue="base-preReq-devops" \
			ParameterKey="CfCrossAccountProdRoleArn",ParameterValue=$(shell $(call getOutputValueOfStack,cfBasePipeline-CrossAcount-Role-prod,${AWS_PROD_PROFILE},CrossAccount-Role)) \
		--capabilities CAPABILITY_NAMED_IAM \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name cfBasePipeline-Role-devops  \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}
	@echo "successful created!"

_putKmsPolicy:
	@aws kms put-key-policy \
        --policy-name default \
        --key-id $(shell $(call getOutputValueOfStack,base-preReq-devops,${AWS_DEVOPS_PROFILE},kms)) \
        --policy file://stacks/cicd/base-infrastructure/devops/cmk-putPolicy.json

_deployBasePipeline:
	@echo -e "\n Creating the base-cfPipeline-dev Stack..."
	@aws cloudformation create-stack \
		--stack-name cfBasePipeline-devops \
		--template-body file://stacks/cicd/base-infrastructure/devops/basepipeline/template.yaml \
		--parameters ParameterKey="ProdAccount",ParameterValue="496106771575" \
			ParameterKey="gitHubOAuthToken",ParameterValue=${GITHUB_TOKEN} \
			ParameterKey="PreReqStack",ParameterValue="base-preReq-devops" \
			ParameterKey="CodePipelineRoleStack",ParameterValue="cfBasePipeline-Role-devops" \
			ParameterKey="CfBasePipelineCrossAccountProdRoleArn",ParameterValue=$(shell $(call getOutputValueOfStack,cfBasePipeline-CrossAcount-Role-prod,${AWS_PROD_PROFILE},cfBasePipeline-CrossAccount-Role)) \
			ParameterKey="CfDeployerCrossAccountProdRoleArn",ParameterValue=$(shell $(call getOutputValueOfStack,cfBasePipeline-CrossAcount-Role-prod,${AWS_PROD_PROFILE},cloudformationdeployer-role)) \
		 --profile ${AWS_DEVOPS_PROFILE} \
		 --region ${AWS_REGION} \
		 --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name cfBasePipeline-devops \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}
	@echo "successful created!"

# ---------------------------------------------
# CREATE CLIMATE_MS-SPECIFIC-INFRASTRUCTURE:
# ---------------------------------------------

_deployClimateInfraPipeline:
	@echo -e "\n Creating the base-cfPipeline-dev Stack..."
	@aws cloudformation create-stack \
		--stack-name climateCfPipeline-devops \
		--template-body file://stacks/cicd/climate/devops/infra-pipeline.yaml \
		--parameters \
			ParameterKey="DevOpsAccountId",ParameterValue="147376585776" \
			ParameterKey="CmkArn",ParameterValue=${GITHUB_TOKEN} \
			ParameterKey="PreReqStack",ParameterValue="base-preReq-devops" \
			ParameterKey="CodePipelineRoleStack",ParameterValue="cfBasePipeline-Role-devops" \
			ParameterKey="CfBasePipelineCrossAccountProdRoleArn",ParameterValue=$(shell $(call getOutputValueOfStack,cfBasePipeline-CrossAcount-Role-prod,${AWS_PROD_PROFILE},cfBasePipeline-CrossAccount-Role)) \
			ParameterKey="CfDeployerCrossAccountProdRoleArn",ParameterValue=$(shell $(call getOutputValueOfStack,cfBasePipeline-CrossAcount-Role-prod,${AWS_PROD_PROFILE},cloudformationdeployer-role)) \
		 --profile ${AWS_DEVOPS_PROFILE} \
		 --region ${AWS_REGION} \
		 --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name climateCfPipeline-devops \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}
	@echo "successful created!"


# ---------------------------------------------
# CREATE CLIMATE_MS-PIPELINE-FOR-CODE_DEPLOYMENT:
# ---------------------------------------------

_deployMsEcrCrossAccountRoleToProd:
	@echo -e "\n Deploy MsEcrCrossAccountRole to Prod..."
	@aws cloudformation create-stack \
		--stack-name msEcrCrossAccountRole \
		--template-body file://stacks/cicd/climate/devops/ms-pipeline-env-role.yaml \
		--parameters \
			ParameterKey="DevOpsAccountId",ParameterValue="147376585776" \
			ParameterKey="CmkArn",ParameterValue=$(shell $(call getOutputValueOfStack,base-preReq-devops,${AWS_DEVOPS_PROFILE},kms)) \
			ParameterKey="ArtifactBucketName",ParameterValue=$(shell $(call getOutputValueOfStack,base-preReq-devops,${AWS_DEVOPS_PROFILE},artifact)) \
		 --profile ${AWS_PROD_PROFILE} \
		 --region ${AWS_REGION} \
		 --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name msEcrCrossAccountRole \
		--profile ${AWS_PROD_PROFILE} \
		--region ${AWS_REGION}
	@echo "Successful created!"

_putEcrPermissionPolicy:
	@echo -e "\n Put EcrPermissionPolicy..."
	@aws ecr set-repository-policy \
         --repository-name "climate-ecr-dev" \
         --policy-text "file://stacks/cicd/climate/prod/put-ecr-policy.json" \
		 --profile ${AWS_PROD_PROFILE} \
         --region ${AWS_REGION}

_deployClimateCodePipeline:
	@echo -e "\n Creating the climate-codePipeline-dev Stack..."
	@aws cloudformation create-stack \
		--stack-name climate-codePipeline \
		--template-body file://stacks/cicd/climate/devops/ms-pipeline.yaml \
		--parameters \
			ParameterKey="gitHubOAuthToken",ParameterValue=${GITHUB_TOKEN} \
			ParameterKey="PreReqStack",ParameterValue="base-preReq-devops" \
			ParameterKey="MsEcrCrossAccountRole",ParameterValue=$(shell $(call getOutputValueOfStack,msEcrCrossAccountRole,${AWS_PROD_PROFILE},MsEcrCrossAccountRole)) \
			ParameterKey="EcsClusterName",ParameterValue="base-ecsCluster-dev" \
			ParameterKey="EcsServiceName",ParameterValue="climate-dev-service" \
			ParameterKey="GitRepoName",ParameterValue="climate" \
		 --profile ${AWS_DEVOPS_PROFILE} \
		 --region ${AWS_REGION} \
		 --capabilities CAPABILITY_NAMED_IAM

	@echo "Waiting till all resources have been created... this can take some minutes"
	@aws cloudformation wait stack-create-complete \
		--stack-name climate-codePipeline \
		--profile ${AWS_DEVOPS_PROFILE} \
		--region ${AWS_REGION}
	@echo "Successful created!"

_putCmkPolicy:
	@aws kms put-key-policy \
        --policy-name default \
        --key-id $(shell $(call getOutputValueOfStack,base-preReq-devops,${AWS_DEVOPS_PROFILE},aws:kms)) \
        --policy file://stacks/cicd/climate/devops/put-cmkPolicy.json

_putS3BucketPolicy:
	@aws s3api put-bucket-policy \
		--bucket artifactbucket-smartoffice-cf-sourcecode \
		--policy file://stacks/cicd/climate/devops/put-s3BucketPolicy.json

# -----------
# DESTROY:
# -----------
_destroyProdStacks:

	@echo " ======Destroying the Prod-Stacks======"
	@echo -e "\n Start deletion of Prod-EcsTaskAndService"
	@aws cloudformation delete-stack --stack-name climate-ecsTaskAndService-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name climate-ecsTaskAndService-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-DynamoDB"
	@aws cloudformation delete-stack --stack-name climate-ddb-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name climate-ddb-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-Ecr"
	@aws cloudformation delete-stack --stack-name climate-ecr-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name climate-ecr-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-ELB"
	@aws cloudformation delete-stack --stack-name base-elb-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-elb-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-ECSCluster"
	@aws cloudformation delete-stack --stack-name base-ecsCluster-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-ecsCluster-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of Prod-VPC"
	@aws cloudformation delete-stack --stack-name base-vpc-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-vpc-dev --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of cfBasePipeline-CrossAcount-Role-prod"
	@aws cloudformation delete-stack --stack-name cfBasePipeline-CrossAcount-Role-prod --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name cfBasePipeline-CrossAcount-Role-prod --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "======Deletion of Prod-Stacks successful finished!======"

	@echo -e "\n Start deletion of msEcrCrossAccountRole"
	@aws cloudformation delete-stack --stack-name msEcrCrossAccountRole --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name msEcrCrossAccountRole --region ${AWS_REGION} --profile ${AWS_PROD_PROFILE}
	@echo "======Deletion of Prod-Stacks successful finished!======"

_destroyDevOpsStacks:
	@echo -e "\n ======Destroying the DevOps-Stacks======"
	@echo -e "\n Start deletion of cfBasePipeline"
	@aws cloudformation delete-stack --stack-name cfBasePipeline-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name cfBasePipeline-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of cfBasePipeline-Role"
	@aws cloudformation delete-stack --stack-name climateCfPipeline-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name climateCfPipeline-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion of cfBasePipeline-Role"
	@aws cloudformation delete-stack --stack-name cfBasePipeline-Role-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name cfBasePipeline-Role-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   Deletion successful finished!"

	@echo -e "\n Start deletion PreReq-Stack"
	@echo "   => firstly, empty the ArtifactBucket and remove it afterwards:"
	@aws s3 rb s3://artifactbucket-smartoffice-cf-sourcecode --force
	@echo "   => Delete Stack itself now:"
	@aws cloudformation delete-stack --stack-name base-preReq-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-preReq-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   Deletion successful finished!"
	@echo "======Deletion of DevOps-Stacks successful finished!======"
# MsInfrastructurePipeline Stacks:

# MsCodePipeline Stacks:
	@echo -e "\n Start deletion PreReq-Stack"
	@echo "   => Delete Stack itself now:"
	@aws cloudformation delete-stack --stack-name climate-codePipeline --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name climate-codePipeline --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   Deletion successful finished!"
	@echo "======Deletion of DevOps-Stacks successful finished!======"

# ####################################################################################################################################
# CI / CD - PIPELINE FOR CLIMATE-MICROSERVICE INFRASTRUCTURE
# ####################################################################################################################################


# ####################
# Helper-Functions
# ####################

# get the OutputValue of a specific stack that matches with the 'searchValue'
# Function-Arguments:
# 	${1} = stackName
# 	${2} = aws-profile(environment)
# 	${3} = searchValue which must be available in OutputValue-Attribute of .describe-stacks cli-command. Returns then the matching OutputValue.
define getOutputValueOfStack
	aws cloudformation describe-stacks --stack-name ${1} --profile ${2} --region ${AWS_REGION} | jq '.Stacks[] | .Outputs[] | select(.OutputValue | contains("${3}")) | .OutputValue'
endef

test:
	$(call getOutputValueOfStack,base-preReq-devops,${AWS_DEVOPS_PROFILE},aws:kms)

getStackInfo:
	@aws cloudformation describe-stacks --stack-name base-preReq-devops --profile ${AWS_DEVOPS_PROFILE} --region ${AWS_REGION}

_deleteClimateCodePipeline:
	@echo -e "\n Start deletion PreReq-Stack"
	@echo "   => firstly, empty the ArtifactBucket and remove it afterwards:"
	@aws s3 rb s3://artifactbucket-smartoffice-cf-sourcecode --force
	@echo "   => Delete Stack itself now:"
	@aws cloudformation delete-stack --stack-name base-preReq-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   wait for deletion..."
	@aws cloudformation wait stack-delete-complete --stack-name base-preReq-devops --region ${AWS_REGION} --profile ${AWS_DEVOPS_PROFILE}
	@echo "   Deletion successful finished!"
	@echo "======Deletion of DevOps-Stacks successful finished!======"
