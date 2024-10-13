import boto3
import subprocess
import time

# Initialize Boto3 S3 client
s3_client = boto3.client('s3')

def run_terraform_command(command):
    """Run Terraform command in a subprocess and capture output."""
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        raise Exception(f"Command failed with error: {stderr.decode('utf-8')}")
    return stdout.decode('utf-8')

def check_s3_bucket_exists(bucket_name):
    """Check if S3 bucket exists using Boto3."""
    try:
        s3_client.head_bucket(Bucket=bucket_name)
        return True
    except s3_client.exceptions.ClientError:
        return False

def main():
    # Path to your Terraform configuration
    terraform_directory = "../path-to-your-terraform-code"

    # Initialize and apply Terraform
    try:
        print("Running Terraform Init...")
        run_terraform_command(f"terraform -chdir={terraform_directory} init")
        print("Running Terraform Apply...")
        run_terraform_command(f"terraform -chdir={terraform_directory} apply -auto-approve")
    except Exception as e:
        print(f"Error during Terraform apply: {e}")
        return

    # Allow some time for resources to be created
    time.sleep(30)

    # Replace with your actual S3 bucket name output from Terraform
    bucket_name = "test-bucket-name"

    # Check if the S3 bucket exists
    print(f"Checking if S3 bucket {bucket_name} exists...")
    if check_s3_bucket_exists(bucket_name):
        print(f"S3 bucket {bucket_name} exists!")
    else:
        print(f"S3 bucket {bucket_name} does not exist!")
    
    # Destroy the Terraform infrastructure
    try:
        print("Running Terraform Destroy...")
        run_terraform_command(f"terraform -chdir={terraform_directory} destroy -auto-approve")
    except Exception as e:
        print(f"Error during Terraform destroy: {e}")
        return

    print("Terraform destroy complete!")

if __name__ == "__main__":
    main()
