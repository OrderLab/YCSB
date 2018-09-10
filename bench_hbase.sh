#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 HBASE_HOME"
  exit 1
fi

hbase_home=$1
if [ ! -d $hbase_home ]; then
  echo "HBASE home $hbase_home does not exist"
  exit 1
fi
if [ ! -x $hbase_home/bin/hbase ]; then
  echo "Could not find hbase in $hbase_home"
  exit 1
fi
output=hbase.`date +"%Y-%m-%d_%H_%M_%S"`.dat

$hbase_home/bin/hbase shell hbase12/create.txt 2>/dev/null
echo "Loading data..." | tee -a $output
bin/ycsb load hbase12 -P workloads/workloada -P large.dat -s -cp $hbase_home/conf -p table=usertable -p columnfamily=family >>$output 2>&1
for ((i=1; i <= 20; i++))
do
  echo "Running read-only workloada, iteration $i..." | tee -a $output
  bin/ycsb run hbase12 -P workloads/workload_rdonly -P large.dat -s -cp $hbase_home/conf -p table=usertable -p columnfamily=family >>$output 2>&1
  echo "Running write-only workloada, iteration $i..." | tee -a $output
  bin/ycsb run hbase12 -P workloads/workload_wronly -P large.dat -s -cp $hbase_home/conf -p table=usertable -p columnfamily=family >>$output 2>&1
done
