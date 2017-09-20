#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

DIR_OF_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR_OF_SCRIPT/utils.sh"

function usage {
  print_color "usage $0 <out-dir> <df-job-id>" RED
  echo
  print_color "\tout-dir: output dir" RED
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
OUTDIR=${1?$(usage)"specify out dir"}
JOBID=${2?$(usage)"specify job id"}

# we could lockfile this file to prevent multiple concurrent
# executions. for new KISS.
LAST_WORKERS_STATE=/tmp/last_workers.txt

### Logic

NEW_WORKERS_STATE=$(mktemp /tmp/new_workers.txt.XXXX)

"$DIR_OF_SCRIPT/get_df_workers.sh" $JOBID | jq -r '.[].instance' | sort > $NEW_WORKERS_STATE

if ! diff -q $LAST_WORKERS_STATE $NEW_WORKERS_STATE ; then
  mv $NEW_WORKERS_STATE $LAST_WORKERS_STATE
  "$DIR_OF_SCRIPT/gen_jmxtrans_yaml.sh" $OUTDIR $JOBID
else 
  echo "No change in workers" >&2
fi
