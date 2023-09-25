#!/bin/bash

# preflight_checks will check if requirements for this check are met.
preflight_checks() {
  kubectl version
}

check_node_groups() {
    web_count=$(kubectl get nodes --selector=${NODE_TYPE_LABEL}=web -o=jsonpath='{.items[*].metadata.name}' | wc -w)
    if [[ $web_count != 0 ]]; then
        echo "Web node group is present !"
        exit 0
    else
        echo "Web node group is not present..."
        exit 1
    fi

    voip_count=$(kubectl get nodes --selector=${NODE_TYPE_LABEL}=voip -o=jsonpath='{.items[*].metadata.name}' | wc -w)
    if [[ $voip_count != 0 ]]; then
        echo "Voip node group is present !"
        exit 0
    else
        echo "Voip node group is not present..."
        exit 1
    fi

    media_count=$(kubectl get nodes --selector=${NODE_TYPE_LABEL}=media -o=jsonpath='{.items[*].metadata.name}' | wc -w)
    if [[ $media_count != 0 ]]; then
        echo "Media node group is present !"
        exit 0
    else
        echo "Media node group is not present..."
        exit 1
    fi
}