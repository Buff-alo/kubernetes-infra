import boto3
from botocore.client import Config
import os
import dotenv

dotenv.load_dotenv(
    dotenv_path=os.path.join(os.path.dirname(__file__), ".env"), override=True
)


# Replace these placeholders with your credentials and endpoint
ACCESS_KEY = os.getenv("ACCESS_KEY")
SECRET_KEY = os.getenv("SECRET_KEY")
ENDPOINT_URL = "https://1cc27ec550fa601e38cdc7dde4a38120.r2.cloudflarestorage.com"
BUCKET_NAME = "rxticket"

# print(ACCESS_KEY)
# print(SECRET_KEY)
# print(ENDPOINT_URL)
# print(BUCKET_NAME)

# Initialize the S3 client with path-style addressing for S3-compatible storage like MinIO
s3_client = boto3.client(
    "s3",
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
    endpoint_url=ENDPOINT_URL,
    region_name="auto",
    config=Config(signature_version="s3v4", s3={"addressing_style": "path"}),
)

try:
    # Test by listing buckets (a simple connectivity check)
    response = s3_client.list_buckets()
    print("Connection successful! Buckets:")
    for bucket in response["Buckets"]:
        print(f"  {bucket['Name']}")

    # Example: Create a test file and upload it
    test_file_content = "Example file content for testing."
    with open("local_test_file.txt", "w") as f:
        f.write(test_file_content)

    s3_client.upload_file("local_test_file.txt", BUCKET_NAME, "remote_test_object.txt")
    print(
        f"Successfully uploaded local_test_file.txt to {BUCKET_NAME}/remote_test_object.txt"
    )
    os.remove("local_test_file.txt")

except Exception as e:
    print(f"Connection failed: {e}")
