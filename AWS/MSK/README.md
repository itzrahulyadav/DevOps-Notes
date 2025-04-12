### Download Kafka binaries: 
wget https://archive.apache.org/dist/kafka/3.5.1/kafka_2.13-3.5.1.tgz.
Extract: tar -xzf kafka_2.13-3.5.1.tgz.
Navigate: cd kafka_2.13-3.5.1.



### Create Topic

./bin/kafka-topics.sh --bootstrap-server <bootstrap-servers> --command-config client.properties --create --topic test-topic --partitions 3 --replication-factor 3

### Create a client.properties file with this content:

```
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required;
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler


```

### Install java

```
sudo dnf install java-11-amazon-corretto -y

```


### list topics

```
./kafka-topics.sh --bootstrap-server boot-hndm7fzf.c2.kafka-serverless.ap-south-1.amazonaws.com:9098 --command-config client.properties --list

```









