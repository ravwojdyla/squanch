#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

DIR_OF_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR_OF_SCRIPT/utils.sh"

function usage {
  print_color "usage $0 <df-job-id>" RED
  echo
  print_color \
    "\tdf-job-id: dataflow service job id (eg: 2016-11-07_08_29_43-5044437533977876133)" RED
  exit 1
}

function check_prereq {
  if ! which kubectl &>/dev/null; then
    fatal_error "kubectl not available - install kubernetes!"
  fi
}

### Prepare

check_prereq
JOBID=${1?$(usage)"specify job id"}

### Logic

PODFILE="$DIR_OF_SCRIPT/../conf/pod.yaml"
NEW_PODFILE=$(mktemp /tmp/pod.yaml.XXXX)

cat $PODFILE | sed "s#???#\"$JOBID\"#" > $NEW_PODFILE
kubectl create -f $NEW_PODFILE
