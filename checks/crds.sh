#!/bin/bash

CONF_FILE=./crds_conf.sh

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

check_crds() {
  crds_count=$(($(wc -l < $CONF_FILE) / 2))
  exit_code=0

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