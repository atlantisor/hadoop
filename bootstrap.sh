#!/bin/bash

env

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -


IP=`ifconfig eth0 |grep "inet addr"| cut -f 2 -d ":"|cut -f 1 -d " "`
#echo "ipaddress=$IP"

# obtain and print the params
type=$1
shift
defaultCmd=$1
shift
masterIP=$1
shift
hdfsPort=$1
shift
hdfsReplication=$1
shift
nameNodeHttpPort=$1
shift
dataNodePort=$1
shift
dataNodeHttpPort=$1
shift
dataNodeIPCPort=$1
shift
rmSchedulerPort=$1
shift
rmResourceTrackerPort=$1
shift
rmPort=$1
shift
rmAdminPort=$1
shift
rmWebAppPort=$1
shift
nmLocalizerPort=$1
shift
nmWebAppPort=$1
shift
mrShufflePort=$1

echo "Namenode or datanode:$type"
echo "Default command:$defaultCmd"
echo "Master ip:$masterIP"
echo "Hdfs port:$hdfsPort"
echo "Hdfs replication:$hdfsReplication"
echo "Hdfs NameNode http port:$nameNodeHttpPort"
echo "Hdfs DataNode port:$dataNodePort"
echo "Hdfs DataNode http port:$dataNodeHttpPort"
echo "Hdfs DataNode ipc port:$dataNodeIPCPort"
echo "ResourceManager scheduler port:$rmSchedulerPort"
echo "ResourceManager resource tracker port:$rmResourceTrackerPort"
echo "ResourceManager port:$rmPort"
echo "ResourceManager admin port:$rmAdminPort"
echo "ResourceManager webapp port:$rmWebAppPort"
echo "NodeManager localizer port:$nmLocalizerPort"
echo "NodeManager webapp port:$nmWebAppPort"
echo "Mapreduce shuffle port:$mrShufflePort"

# altering the core-site,yarn-site,hdfs-site configuration
sed -i s/__MASTER__/$masterIP/ /usr/local/hadoop/etc/hadoop/core-site.xml
sed -i s/__MASTER__/$masterIP/ /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i s/__HDFS_PORT__/$hdfsPort/ /usr/local/hadoop/etc/hadoop/core-site.xml

#sed -i s/__HDFS_REP__/$hdfsReplication/ /usr/local/hadoop/etc/hadoop/hdfs-site.xml
sed -i s/__HDFS_REP__/1/ /usr/local/hadoop/etc/hadoop/hdfs-site.xml

sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>dfs.namenode.http-address<\/name>\n\t\t<value>0.0.0.0:$nameNodeHttpPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/hdfs-site.xml

sed -i s/__HDFS_DATANODE_PORT__/$dataNodePort/ /usr/local/hadoop/etc/hadoop/hdfs-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>dfs.datanode.http.address<\/name>\n\t\t<value>0.0.0.0:$dataNodeHttpPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/hdfs-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>dfs.datanode.ipc.address<\/name>\n\t\t<value>0.0.0.0:$dataNodeIPCPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/hdfs-site.xml

sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.resourcemanager.scheduler.address<\/name>\n\t\t<value>$masterIP:$rmSchedulerPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.resourcemanager.resource-tracker.address<\/name>\n\t\t<value>$masterIP:$rmResourceTrackerPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.resourcemanager.address<\/name>\n\t\t<value>$masterIP:$rmPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.resourcemanager.admin.address<\/name>\n\t\t<value>$masterIP:$rmAdminPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.resourcemanager.webapp.address<\/name>\n\t\t<value>$masterIP:$rmWebAppPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.nodemanager.localizer.address<\/name>\n\t\t<value>0.0.0.0:$nmLocalizerPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml
sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>yarn.nodemanager.webapp.address<\/name>\n\t\t<value>0.0.0.0:$nmWebAppPort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/yarn-site.xml

sed -i "/<\/configuration>/i\ \t<property>\n\t\t<name>mapreduce.shuffle.port<\/name>\n\t\t<value>$mrShufflePort<\/value>\n\t<\/property>" /usr/local/hadoop/etc/hadoop/mapred-site.xml

#start NameNode and DataNode

cd $HADOOP_HOME
service sshd start

if [ $type = "N" ] ; then
    echo "starting Hadoop Namenode,resourcemanager"
    
    #rm -rf  /tmp/hadoop-root
    $HADOOP_PREFIX/bin/hdfs namenode -format -nonInteractive > /dev/null 2>&1
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh  start namenode > /dev/null 2>&1
    echo "Succeed to start namenode"
    
    $HADOOP_PREFIX/sbin/yarn-daemon.sh  start resourcemanager > /dev/null 2>&1
    echo "Succeed to start resourcemanager"


    #$HADOOP_PREFIX/sbin/hadoop-daemon.sh  start datanode > /dev/null 2>&1
    #echo "Succeed to start datanode"

    #$HADOOP_PREFIX/sbin/yarn-daemon.sh  start nodemanager > /dev/null 2>&1
    #echo "Succeed to start nodemanager"

    #wait for namenode startup and then set its safemode leave 
    tryCount=1
    while(($tryCount<=40))
    do
        echo "The time to start to trying set HDFS safemode: $tryCount"
        sleep 3
        #detect whether HDFS name node is started
        name_node_process_num=`netstat  -plan | grep $hdfsPort | wc -l`
        if [ $name_node_process_num -ge 1 ]; then
            echo "setting HDFS safemode..."
            $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave
            echo "Done set HDFS safemode"
            break
        fi
        let "tryCount++"
    done
else
    echo "starting Hadoop Datanode,nodemanager"
    
    #rm -rf  /tmp/hadoop-root
    $HADOOP_PREFIX/sbin/hadoop-daemon.sh  start datanode > /dev/null 2>&1
    echo "Succeed to start datanode"

    $HADOOP_PREFIX/sbin/yarn-daemon.sh  start nodemanager > /dev/null 2>&1
    echo "Succeed to start nodemanager"
fi

if [[ $defaultCmd == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $defaultCmd == "-bash" ]]; then
  /bin/bash
fi


