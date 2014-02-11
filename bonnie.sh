#!/bin/bash

base=${0%/*}
. ${0%/*}/config

usage() {
  echo "Usage:
$0 time mountpoint [mountpoint ...]"
  exit 1
}

cdir=$(pwd)
fstest_dir=/opt/fstest
(( $# <1 )) && usage
t=$1
shift
ts=$(date +%s)
while (( ts + t >= $(date +%s) )); do
  d=$(date +%F_%T)
  mkdir -p $results_dir/bonnie/$d
  rm $results_dir/bonnie/$d/results.out 2>/dev/null
  touch $results_dir/bonnie/$d/results.out
  pids=""
  for mount in $mountpoints; do
    mkdir -p $results_dir/bonnie/$d/$mount || exit 1
    cd $mount
    mkdir -p $mount/$(hostname)
    cd $mount/$(hostname)
    bonnie++ -d $mount/$(hostname) -c 2 -s 768 -n 1 -r 768 -x 10 -u 0 -g 0 -q -D 2>&1 1>$results_dir/bonnie/$d/$mount/results.out &
    pids="$pids|$!"
  done
  pids=${pids#|}
  echo "Pids: $pids"
  while [[ $(ps -e -o pid |egrep "$pids" |wc -l) != *0 ]]; do sleep 10; done
done
cd $cdir
exit 0
