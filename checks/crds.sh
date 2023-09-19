#!/bin/bash

CONF_FILE=./crds_conf.sh

preflight_checks() {
  kubectl version > /dev/null
  source $CONF_FILE
}

check_crds() {
  crds_count=$(($(wc -l < $CONF_FILE) / 2))
  exit_code=0

  for i in $(seq 0 $(($crds_count - 1))); do
    name=crds_${i}_name
    version=crds_${i}_version

    kubectl get crd/"${!name}" -o=jsonpath='{.spec.versions[*].name}' | grep -w "${!version}" > /dev/null
    if [[ $? == 0 ]]; then
        echo "CRD ${!name} supports ${!version} !"
        exit_code=1
    else
        echo "CRD ${!name} doesn't support version ${!version}."
    fi
  done

  exit $exit_code
}

preflight_checks
check_crds