import { SQSClient, SendMessageCommand } from "@aws-sdk/client-sqs"; 

const client = new SQSClient({ region: "ap-south-1" });

const input = { 
  QueueUrl: "https://sqs.ap-south-1.amazonaws.com/533267257785/StandardQueue", 
  MessageBody: "This message was sent using nodejs"
 
};
const command = new SendMessageCommand(input);
const response = await client.send(command);


