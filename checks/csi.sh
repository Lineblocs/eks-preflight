#!/bin/bash

CONF_FILE=./csi_conf.sh

# preflight_checks will check if requirements for this check are met.
# This one will also install yq, convert yaml conf in shell format and source it.
preflight_checks() {
    apt update
    apt install -y wget
    wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
    chmod a+x /usr/local/bin/yq
    yq -o=shell /conf/csi_conf.yaml > ./csi_conf.sh

    yq -V > /dev/null
    kubectl version > /dev/null
    source $CONF_FILE
}

# check_at_least_one checks if at least one CSIDriver is configured.
# It can be ebs, efs or anything.
# Returns with 0 if present, 1 if not.
check_at_least_one() {
  echo -e "Using 'at least one' mode for CSI driver check...\n"

  drivers=$(kubectl get csidrivers.storage.k8s.io -o=jsonpath='{.items[*].metadata.name}' | wc -w)
  if [ "$drivers" == "0" ]; then
    echo "No CSI driver is present. Your PVC will stay in pending state."
    exit 1
  else
    echo "There is at least one CSI driver !"
    exit 0
  fi
}

# check_regex checks if the list of returned CSIDriver matches a given regex.
# The format of this list is : <driver1_name> <driver2_name> ...
# Please note that this needs an exact match to be ok.
# It can be ebs, efs or anything.
# Returns with 0 if present, 1 if not.
check_regex() {
    if [ -z "$csi_regex" ]; then
      echo "You need to pass a regex in order to use this mode. Please refer to the documentation."
      exit 1
    fi

    echo -e "Using 'one present' mode for CSI driver check...\n"
    kubectl get csidrivers.storage.k8s.io -o=jsonpath='{.items[*].metadata.name}' | grep -w "$csi_regex"
    if [[ $? == 0 ]]; then
        echo "The given regex matches. CSI drivers are ok !"
        exit 0
    else
        echo "Drivers in the regex are not all present."
        exit 1
    fi
}

preflight_checks

case $CHECK_MODE in

  ATLEASTONE)
    check_at_least_one
    ;;

  REGEX)
    check_regex
    ;;

  ONEPRESENT)
    # TODO: do this mode too
    ;;

  ALLPRESENT)
    # TODO: do this mode too
    ;;

esac