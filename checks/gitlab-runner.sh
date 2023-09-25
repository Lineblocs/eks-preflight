#!/bin/bash

# preflight_checks will check if requirements for this check are met.
preflight_checks() {
  kubectl version
}

check_cloudwatch_presence