from confluent_kafka import Consumer, KafkaException
from aws_msk_iam_sasl_signer import MSKAuthTokenProvider

class MSKTokenProvider:
    def __init__(self, region='ap-south-1'):
        self.region = region

    def token(self):
        return MSKAuthTokenProvider.generate_auth_token(self.region)

conf = {
    'bootstrap.servers': 'boot-hndm7fzf.c2.kafka-serverless.ap-south-1.amazonaws.com:9098',
    'security.protocol': 'SASL_SSL',
    'sasl.mechanism': 'AWS_MSK_IAM',
    'sasl.client.callback.handler': MSKTokenProvider(),
    'group.id': 'test-consumer-group',
    'auto.offset.reset': 'earliest',
}

consumer = Consumer(conf)
consumer.subscribe(['test-topic'])

print("Waiting for messages...")
try:
    while True:
        msg = consumer.poll(timeout=1.0)
        if msg is None:
            continue
        if msg.error():
            raise KafkaException(msg.error())
        print(f"Received: {msg.value().decode('utf-8')} from partition {msg.partition()}")
except KeyboardInterrupt:
    print("Stopping consumer...")
finally:
    consumer.close()
