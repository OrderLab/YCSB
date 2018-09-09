#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 CASSANDRA_HOME"
  exit 1
fi

cassandra_home=$1
if [ ! -d $cassandra_home ]; then
  echo "Cassandra home $cassandra_home does not exist"
  exit 1
fi
if [ ! -x $cassandra_home/bin/cqlsh ]; then
  echo "Could not find cqlsh in $cassandra_home"
  exit 1
fi
output=cassandra.`date +"%Y-%m-%d_%H_%M_%S"`.dat

$cassandra_home/bin/cqlsh -f cassandra/create.sql 2>/dev/null
echo "Loading data..." | tee -a $output
bin/ycsb load cassandra-cql -P workloads/workloada -P large.dat -p hosts=localhost -s >>$output 2>&1
for ((i=1; i <= 20; i++))
do
  echo "Running read-only workloada, iteration $i..." | tee -a $output
  bin/ycsb run cassandra-cql -P workloads/workload_rdonly -P large.dat -p hosts=localhost -s >>$output 2>&1
  echo "Running write-only workloada, iteration $i..." | tee -a $output
  bin/ycsb run cassandra-cql -P workloads/workload_wronly -P large.dat -p hosts=localhost -s >>$output 2>&1
done
