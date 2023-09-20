#!/bin/bash

CONF_FILE=./crds_conf.sh

# preflight_checks will check if requirements for this check are met.
# This one will also install yq, convert yaml conf in shell format and source it.
preflight_checks() {
  apt update
  apt install -y wget
  wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
  chmod a+x /usr/local/bin/yq
  yq -o=shell /conf/crds_conf.yaml > ./crds_conf.sh

  yq -V > /dev/null
  kubectl version > /dev/null
  source $CONF_FILE
}

# check_crds checks if every crds in CONF_FILE is under the correct version.
# Please note that this needs an exact match to be ok.
# Returns with 0 if present, 1 if not.
check_crds() {
  # We divide by 2 because for each CRD we have name and version variable which doubles line count.
  crds_count=$(($(wc -l < $CONF_FILE) / 2))
  exit_code=0

  # Will go through each CRD, and return 1 if at least one doesn't match the wanted version.
  for i in $(seq 0 $(($crds_count - 1))); do
    name=crds_${i}_name
    version=crds_${i}_version

    kubectl get crd/"${!name}" -o=jsonpath='{.spec.versions[*].name}' | grep -w "${!version}" > /dev/null
    if [[ $? == 0 ]]; then
        echo "CRD ${!name} supports ${!version} !"
    else
        echo "CRD ${!name} doesn't support version ${!version}."
        exit_code=1
    fi
  done

  exit $exit_code
}

preflight_checks
check_crds