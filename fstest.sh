#!/bin/bash

base=${0%/*}
. ${0%/*}/config

usage() {
  echo "Usage:
$0 time mountpoint [mountpoint ...]"
  exit 1
}

t=$1
shift
cdir=$(pwd)
fstest_dir=/opt/fstest
(( $# <1 )) && usage
total_f=0
total_p=0
ts=$(date +%s)
while (( ts + t >= $(date +%s) )); do
  d=$(date +%F_%T)
  mkdir -p $results_dir/fstest_run/$d
  rm $results_dir/fstest_run/$d/results.out 2>/dev/null
  touch $results_dir/fstest_run/$d/results.out
  for mount in $@; do
    mkdir -p $results_dir/fstest_run/$d/$mount || exit 1
    cd $mount
    mkdir -p $mount/$(hostname)
    cd $mount/$(hostname)
    exec > $results_dir/fstest_run/$d/$mount/results.out 2>&1
    for i in $(find $fstest_dir/tests/* -type d -print); do
      for j in $(ls -1 $i/*); do
        echo "Test: $j"
        $j
      done
    done
    failed=$(grep "not ok" $results_dir/fstest_run/$d/$mount/results.out | wc -l)
    passed=$(grep "ok" $results_dir/fstest_run/$d/$mount/results.out | wc -l)
    echo "Status, failed tests: $failed, passed tests: $passed"
    echo "Status, failed tests: $failed, passed tests: $passed, for mount: $mount" >> $results_dir/fstest_run/$d/results.out
    (( total_f=$total_f+$failed ))
    (( total_p=$total_p+$passed ))
  done
done
cd $cdir
exit 0
