#!/bin/bash

set -e


. /opt/conda/etc/profile.d/conda.sh
conda activate cmap2bed

set -u
cmap=""
enzyme=""

while getopts "t:z:" arg; do
  case $arg in
    h)
      echo "usage"
      ;;
    t)
      cmap=$OPTARG
      ;;
    z)
      enzyme=$OPTARG
      ;;
  esac
done



exec python /scripts/cmap2bed.py -t ${cmap} -z ${enzyme}
