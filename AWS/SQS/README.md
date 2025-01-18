# SQS

## Messaging System
- Used to provide asynchronous communication and decouple processes via messages/events from a sender and reciever
## Queueing System
- It's a messaging system that delete messages once they have are consumed. Polling should be there, not reactive

- SQS uses two types of queues
   - Standard: unlimited messages,but messages are out of order
   - FIFO: limited messages,order is preserved and no duplicate messages
- message size can be 1 to 256 KB
- messages can be retented for 14 days and can be encrypted using kms keys
