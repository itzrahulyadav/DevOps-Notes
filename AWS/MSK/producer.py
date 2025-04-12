from confluent_kafka import Producer
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
}

producer = Producer(conf)

def delivery_report(err, msg):
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to {msg.topic()} [partition {msg.partition()}]')

messages = ["Hello, MSK!", "Test message.", "Serverless Kafka!"]
for msg in messages:
    producer.produce('test-topic', value=msg.encode('utf-8'), callback=delivery_report)

producer.flush()
print("Messages sent!")
