~/hbase/bin/hbase shell hbase10/create.txt
bin/ycsb load hbase10 -P workloads/workloada -P large.dat -s -cp ~/hbase/conf -p table=usertable -p columnfamily=family
bin/ycsb run hbase10 -P workloads/workloada -P large.dat -s -cp ~/hbase/conf -p table=usertable -p columnfamily=family -p recordcount=100000 -p operationcount=50000 > load.dat

