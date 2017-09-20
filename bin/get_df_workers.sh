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
  if ! which jq  &>/dev/null; then
    fatal_error "jq not available - install jq! (https://stedolan.github.io/jq/)"
  fi

  if ! which gcloud &>/dev/null; then
    fatal_error "gcloud not available - install gcloud! (https://cloud.google.com/sdk/)"
  fi
}

### Prepare

check_prereq
JOBID=${1?$(usage)"specify job id"}

### Logic

JOBNAME=$(gcloud --format=json beta dataflow jobs describe $JOBID | jq -r '.name')
# there seems to be a bug, and instance group is trimmed
JOBNAME=\"${JOBNAME::-2}\"
INSTANCEGRP_DATA=$(gcloud --format=json compute instance-groups list \
  | jq -r --arg JOBNAME "$JOBNAME" \
    "map(select( .name | contains ($JOBNAME)))[]|{name: .name, zone: .zone}")

ZONE=$(echo $INSTANCEGRP_DATA | jq .zone -r)
JOBINSTANCEGRP=$(echo $INSTANCEGRP_DATA | jq .name -r)

gcloud --format=json compute instance-groups list-instances $JOBINSTANCEGRP --zone=$ZONE
