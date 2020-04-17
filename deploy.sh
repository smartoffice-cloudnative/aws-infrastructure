#! /bin/bash
AWS_REGION=eu-central-1
AWS_DEVOPS_PROFILE=default

function deployPreRequirementsStack1() {
  stackName=role1
  echo "Creating the $stackName Stack..."
}
function deployPreRequirementsStack2() {
  stackName=role2
  echo "Creating the $stackName Stack..."
}

function getAttributeValueFromStack() {
  stackName=$1
  attrName=$2
  aws cloudformation describe-stacks --stack-name ${stackName} |
    jq -r --arg attrName "$attrName" '.Stacks[] | .Outputs[] | select(.OutputValue | contains($attrName)) | .OutputValue'
}


# -----------
# START:
# -----------
function startDeployment() {
    # 1. Deploy the PreRequirements
    getAttributeValueFromStack base-preReq-devops kms

    # 2. Deploy all relevant roles in the different stages
    deployPreRequirementsStack1
    deployPreRequirementsStack2
}
#start:
startDeployment
