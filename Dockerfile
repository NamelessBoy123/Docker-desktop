# Use the official Ubuntu base image
FROM ubuntu:latest

# Set environment variables for Hadoop
ENV HADOOP_HOME /usr/local/hadoop
ENV PATH $HADOOP_HOME/bin:$PATH
ENV HDFS_NAMENODE_USER=root
ENV HDFS_DATANODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root
ENV YARN_NODEMANAGER_USER=root
ENV YARN_RESOURCEMANAGER_USER=root


# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y ssh openjdk-8-jdk neovim junit && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Hadoop
RUN mkdir -p $HADOOP_HOME
RUN wget -O hadoop.tar.gz https://downloads.apache.org/hadoop/common/stable/hadoop-3.3.6.tar.gz
RUN tar -xzvf hadoop.tar.gz -C $HADOOP_HOME --strip-components=1

# Configure SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

RUN wget -O /usr/local/hadoop/lib/javax.activation-api-1.2.0.jar https://jcenter.bintray.com/javax/activation/javax.activation-api/1.2.0/javax.activation-api-1.2.0.jar

RUN mkdir -p /home/hadoop/hdfs/{namenode,datanode}
RUN chown -R $USER:$USER /home/hadoop/hdfs

# Hadoop configuration
COPY core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml
COPY hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml
COPY mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml
COPY yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml

RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64/bin" >> ~/.bashrc
RUN echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.bashrc
RUN echo "export HADOOP_INSTALL=\$HADOOP_HOME" >> ~/.bashrc
RUN echo "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> ~/.bashrc
RUN echo "export HADOOP_COMMON_HOME=\$HADOOP_HOME" >> ~/.bashrc
RUN echo "export HADOOP_HDFS_HOME=\$HADOOP_HOME" >> ~/.bashrc
RUN echo "export YARN_HOME=\$HADOOP_HOME" >> ~/.bashrc
RUN echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> ~/.bashrc
RUN echo "export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin" >> ~/.bashrc
RUN echo "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\"" >> ~/.bashrc

RUN echo "HDFS_NAMENODE_USER=root" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "HDFS_DATANODE_USER=root" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "HDFS_SECONDARYNAMENODE_USER=root" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "YARN_NODEMANAGER_USER=root" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "YARN_RESOURCEMANAGER_USER=root" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
RUN echo "export HADOOP_CLASSPATH+=\" \$HADOOP_HOME/lib/*.jar\"" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

# Copy init and restart scripts
COPY restart $HADOOP_HOME/bin/restart
COPY init $HADOOP_HOME/bin/init
RUN chmod +x $HADOOP_HOME/bin/restart
RUN chmod +x $HADOOP_HOME/bin/init

# Install pig
RUN wget -O pig.tar.gz https://downloads.apache.org/pig/pig-0.17.0/pig-0.17.0.tar.gz
RUN tar -xzvf pig.tar.gz
RUN mv pig-0.17.0 /pig
RUN echo "export PIG_HOME=/pig" >> ~/.bashrc
RUN echo "export PATH=\$PATH:/pig/bin" >> ~/.bashrc
RUN echo "export PIG_CLASSPATH=\$HADOOP_HOME/etc/hadoop" >> ~/.bashrc

# Install hbase
RUN wget http://apache.mirror.gtcomm.net/hbase/stable/hbase-2.5.7-bin.tar.gz
RUN tar -xzvf hbase-2.5.7-bin.tar.gz
RUN mv hbase-2.5.7 /usr/local/hbase
RUN echo "export HBASE_HOME=/usr/local/hbase" >> ~/.bashrc
RUN echo "export PATH=\$PATH:\$HBASE_HOME/bin" >> ~/.bashrc
RUN echo "export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP=\"true\"" >> /usr/local/hbase/conf/hbase-env.sh
RUN echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-arm64/" >> /usr/local/hbase/conf/hbase-env.sh
COPY hbase-site.xml ~/hbase-site.xml

RUN mkdir -p /hadoop/zookeeper
RUN chown -R $USER:$USER /hadoop/

# Install Hive
RUN wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
RUN tar -xzvf apache-hive-3.1.3-bin.tar.gz
RUN mv apache-hive-3.1.3-bin /usr/local/hive
RUN echo "export HIVE_HOME=/usr/local/hive" >> ~/.bashrc
RUN echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> ~/.bashrc
RUN echo "HADOOP_HOME=/usr/local/hadoop" >> /usr/local/hive/bin/hive-config.sh

# Expose necessary ports
EXPOSE 9870 8088 9000
