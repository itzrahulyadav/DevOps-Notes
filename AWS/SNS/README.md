# SNS
- SNS follow pub/sub system in which they don't send their messages directly to subscribers, instead they send thier messages to an event bus,the
  event bus categorises their messages to groups
- Then recievers of this message subscribe to this groups
- Subscribers do not pull messages
- To publish large messages we can use the libraries called amazon sns extended library for java/python
-  Maximum current size is 256kB,using the library it can be increased to 2 GB
-  The libraries save the payload to s3 bucket and publish the reference of the stored s3 object to the sns topic.
-  SNS supports delivery of message attributes , which let you provide metadata items about the message
-  Batch publishing can be used to publish 10 messages at a time


  ## Message structure
  - Set message structure to json to supply json file as a message if we want to send different kind of messages to different kind of subscribers

  ## Subscriptions
  - To recive message from a topic we need to create subscriptions
