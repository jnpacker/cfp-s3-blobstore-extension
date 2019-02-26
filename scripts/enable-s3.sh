#!/bin/bash
###############################################################################
# Licensed Materials - Property of IBM Copyright IBM Corporation 2017, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure restricted by GSA ADP
# Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
# First we create a var's file that contains the needed AWS credential data
cat << "END_OF_BANNER"
*=============================================================================================*
|   _____             _     _        ____ _____   _     _       _         _                   |
|  | ____|_ __   __ _| |__ | | ___  / ___|___ /  | |__ | | ___ | |__  ___| |_ ___  _ __ ___   |
|  |  _| | '_ \ / _` | '_ \| |/ _ \ \___ \ |_ \  | '_ \| |/ _ \| '_ \/ __| __/ _ \| '__/ _ \  |
|  | |___| | | | (_| | |_) | |  __/  ___) |__) | | |_) | | (_) | |_) \__ \ || (_) | | |  __/  |
|  |_____|_| |_|\__,_|_.__/|_|\___| |____/____/  |_.__/|_|\___/|_.__/|___/\__\___/|_|  \___|  |
*=============================================================================================*
END_OF_BANNER

#log function prefixes a timestamp
function log {
  if [ "$1" == "" ]; then
    echo "ERROR: No log message provided"
    exit 1
  fi
  echo "[" `date` " ] $1"
}

CURRENT_PATH=`pwd`
log "Current PATH: ${CURRENT_PATH}"
log "Extracting AWS Credentials"
spruce merge /data/CloudFoundry/bmxconfig.yml ${CURRENT_PATH}/s3-vars-template.yml > /data/CloudFoundry/ibm-s3-blobstore-extension-vars.yml
if [ $? -ne 0 ]; then
  log "Failed to extract AWS credentials from bmxconfig: aws.access_key_id, aws.secret_access_key, aws.region"
  exit 1
fi

TOOLSDIR=/repo_local/cfp-deployment-tooling/
CF_YML=`find ${TOOLSDIR} -name cf-deployment.yml`
CFDIR=${CF_YML%/*}
log "cfp-deployment-tooling path: \"${CFDIR}\""
log "Enabling S3 blobstore opsfiles:"
cat << "COMMAND_PRINT"
bosh int /data/CloudFoundry/cf-deploy.yml \
  --vars-file /data/CloudFoundry/ibm-s3-blobstore-extension-vars.yml \
  -o ${CURRENT_PATH}/var-stub.yml \
  -o ${CFDIR}/operations/use-external-blobstore.yml \
  -o ${CFDIR}/operations/use-s3-blobstore.yml \

COMMAND_PRINT

bosh int /data/CloudFoundry/cf-deploy.yml \
  --vars-file /data/CloudFoundry/ibm-s3-blobstore-extension-vars.yml \
  -o ${CURRENT_PATH}/var-stub.yml \
  -o ${CFDIR}/operations/use-external-blobstore.yml \
  -o ${CFDIR}/operations/use-s3-blobstore.yml \
  >/data/CloudFoundry/cf-deploy.yml_NEW
if [ $? -ne 0 ]; then
  log "Failed to enable S3 via ops-files"
  exit 1
fi

log "Activating cf-deploy.yml changes"
mv /data/CloudFoundry/cf-deploy.yml_NEW /data/CloudFoundry/cf-deploy.yml
if [ $? -ne 0 ]; then
  log "Failed to move /data/CloudFoundry/cf-deploy.yml_NEW /data/CloudFoundry/cf-deploy.yml"
  exit 1
fi
