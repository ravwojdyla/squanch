#!/bin/bash

set -o nounset
set -o errexit
set -o pipefail

DIR_OF_SCRIPT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR_OF_SCRIPT/utils.sh"

function usage {
  print_color "usage $0 <output-dir> <df-job-id>" RED
  echo
  print_color "\toutput-dir: output dir" RED
  print_color \
    "\tdf-job-id: dataflow service job id (eg: 2016-11-07_08_29_43-5044437533977876133)" RED
  exit 1
}

function check_prereq {
  if ! which jq  &>/dev/null; then
    fatal_error "jq not available - install jq! (https://stedolan.github.io/jq/)"
  fi
}

### Prepare

check_prereq
OUTDIR=${1?$(usage)"specify output dir"}
JOBID=${2?$(usage)"specify job id"}

JMXTEMPLATEFILE="$DIR_OF_SCRIPT/../conf/template.yaml"

### Logic

mkdir -p $OUTDIR

TEMPYAML=$(mktemp /tmp/yamltemplate.XXXX)

if [ ! -f $JMXTEMPLATEFILE ]; then
  fatal_error "jmxtrans template config `$JMXTEMPLATEFILE` not found!"
fi

cat $JMXTEMPLATEFILE > $TEMPYAML

PROJECTID=$(gcloud --format=json beta dataflow jobs describe $JOBID | jq -r '.projectId')

"$DIR_OF_SCRIPT/get_df_workers.sh" $JOBID | jq -r '.[].instance' \
  | xargs -n 1 basename \
  | xargs -n 1 -I {} echo "            - {}" >> $TEMPYAML

"$DIR_OF_SCRIPT/yaml2jmxtrans.py" "$TEMPYAML" "$OUTDIR"
