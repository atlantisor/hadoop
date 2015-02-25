#Apache Hadoop V2.4.1 Docker image


#Pull the basement image
docker pull sequenceiq/hadoop-docker:2.4.1

#Build the image
If you want to build directly from the Dockerfile, you can build the image as:
```
docker build -t="hadoop-cluster-docker:2.4.1" .
```

#Start the container
```
docker run --net=host  hadoop-cluster-docker:2.4.1 $1 $2 $3 $4 $5 $6 $7 $8 $9 $10 $11 $12 $13 $14 $15 $16 $17
Parameter definitions:
$1: Node type, N indicating namenode or D indicating datanode
$2: Run mode indicating which mode to run the container, bash mode (-bash) or daemon mode (-d)
$3: Host name or IP of the namenode
$4: RPC port of the namenode
$5: Number of replications
$6: Web UI port of the namenode
$7: Port of the data node for data transfer
$8: Web UI port of the datanode
$9: IPC port of the datanode
$10: Scheduler interface port in the resource manager
$11: Resource tracker interface port in the resource manager
$12: Port of the application manager interface in the resource manager
$13: Admin interface port of the resource manager
$14: Web application port of the resource manager
$15: Localizer IPC port of the node manager
$16: Web application port of the node manager
$17: ShuffleHandler port of the node manager

#Start the namenode and resource manager
eg: docker run  -i -t --net=host hadoop-cluster-docker:2.4.1 N -bash 10.28.241.172 8020 1 50070 50010 50075 50020 8030 8031 8032 8033 8088 8040 8042 13562

#Start data node and node manager
eg: docker run  -i -t --net=host hadoop-cluster-docker:2.4.1 D -bash 10.28.241.172 8020 1 50070 50010 50075 50020 8030 8031 8032 8033 8088 8040 8042 13562
```

#Testing
You can run one of these stock examples:
```
#Go into the namenode container and execute the following commands to put some files into HDFS
$HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root
$HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input

#Run the mapreduce command
$HADOOP_PREFIX/bin/hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-2.4.1.jar grep input output 'dfs[a-z.]+'

#Check the output
$HADOOP_PREFIX/bin/hdfs dfs -cat output/*
```
