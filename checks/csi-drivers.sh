#!/bin/bash

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

check_regex() {
    if [ -z "$REQUIRED_DRIVERS" ]; then
      echo "You need to pass one or more CSI drivers in order to test"
      exit 1
    fi

    echo -e "Using 'one present' mode for CSI driver check...\n"
    kubectl get csidrivers.storage.k8s.io -o=jsonpath='{.items[*].metadata.name}' | grep -w "$REQUIRED_DRIVERS"
    if [[ $? == 0 ]]; then
        echo "The given regex matches. CSI drivers are ok !"
        exit 0
    else
        echo "Drivers in the regex are not all present."
        exit 1
    fi
}

case $CHECK_MODE in

  ATLEASTONE)
    check_at_least_one
    ;;

  REGEX)
    check_regex
    ;;

  ONEPRESENT)
    ;;

  ALLPRESENT)
    ;;

esac