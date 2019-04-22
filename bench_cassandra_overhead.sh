#!/bin/bash
workloads=("workloada")

repeatrun=1
records=900000
operations=100000
threads=4
driver="cassandra-cql"
hosts="gray0"

for work in "${workloads[@]}"
do
        echo "Loading data for" $work
        ./bin/ycsb load $driver -P ./workloads/$work -p hosts=$hosts -p recordcount=$records -threads 40 > $work"_load.log"

        echo "Running tests"
        for r in `seq 1 $repeatrun`
        do
                ./bin/ycsb run $driver -P ./workloads/$work -p hosts=$hosts -p recordcount=$records -p operationcount=$operations -threads $threads > $work"_run_"$r".log"
        done
        #Truncate table and start over
        cqlsh -f cassandra_truncate $hosts
done
