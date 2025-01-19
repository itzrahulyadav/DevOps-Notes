import boto3 
import logging
from botocore.exceptions import ClientError


print("running the code ")
class ComprehendDetect:
    def __init__(self, comprehend_client):
        self.comprehend_client = comprehend_client
    def detect_sentiment(self, text, language_code):
        try:
            response = self.comprehend_client.detect_sentiment(
                Text=text, LanguageCode=language_code
            )
            # logger.info("Detected primary sentiment %s.", response["Sentiment"])
        except ClientError:
            logger.exception("Couldn't detect sentiment.")
            raise
        else:
            return response

# if __name__ == "main":
#     try:
#     # Initialize the Boto3 Comprehend client
#             comprehend_client = boto3.client("comprehend", region_name="ap-south-1")
#             logger.info("Successfully initialized Comprehend client.")
#     except NoCredentialsError:
#             logger.error("AWS credentials were not found. Please configure your credentials.")
#             raise
#     except PartialCredentialsError:
#             logger.error("Incomplete AWS credentials found. Please check your configuration.")
#             raise
#     except Exception as e:
#             logger.error("An unexpected error occurred: %s", e)
#             raise

comprehend_client = boto3.client("comprehend", region_name="ap-south-1")
comprehend_service = ComprehendDetect(comprehend_client)

sample_text = "Hey everyone, this is Rahul and I am just learning how aws comprehend works"
language = "en"

response = comprehend_service.detect_sentiment(sample_text, language)
print(response["Sentiment"])
print(response["SentimentScore"])