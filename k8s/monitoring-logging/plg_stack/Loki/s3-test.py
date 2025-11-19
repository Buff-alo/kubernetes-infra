import boto3
from botocore.client import Config
import os


# Replace these placeholders with your credentials and endpoint
ACCESS_KEY = os.getenv('ACCESS_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')
ENDPOINT_URL = 'https://minio-api.kwadwolabs.cloud'
BUCKET_NAME = 'loki-chunks'

# Initialize the S3 client with path-style addressing for S3-compatible storage like MinIO
s3_client = boto3.client(
    's3',
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
    endpoint_url=ENDPOINT_URL,
    config=Config(signature_version='s3v4', s3={'addressing_style': 'path'})
)

try:
    # Test by listing buckets (a simple connectivity check)
    response = s3_client.list_buckets()
    print("Connection successful! Buckets:")
    for bucket in response['Buckets']:
        print(f"  {bucket['Name']}")
    
    # Example: Create a test file and upload it
    test_file_content = "Example file content for testing."
    with open("local_test_file.txt", "w") as f:
        f.write(test_file_content)
        
    s3_client.upload_file("local_test_file.txt", BUCKET_NAME, "remote_test_object.txt")
    print(f"Successfully uploaded local_test_file.txt to {BUCKET_NAME}/remote_test_object.txt")
    os.remove("local_test_file.txt")

except Exception as e:
    print(f"Connection failed: {e}")

