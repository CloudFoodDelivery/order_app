import pytest
from botocore.exceptions import ClientError
import boto3

# AWS client setup
rds = boto3.client("rds", region_name="us-east-2")
s3 = boto3.client("s3", region_name="us-east-2")
cloudfront = boto3.client("cloudfront")
route53 = boto3.client("route53", region_name="us-east-1")
cognito = boto3.client("cognito-idp", region_name="us-east-2")

# Define resource identifiers and configurations
DB_INSTANCES = {
    "rds_instance1": {
        "DBInstanceIdentifier": "rds-instance-1",
        "AllocatedStorage": 20,
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "MasterUsername": "username1",
        "MasterUserPassword": "password1"
    },
    "rds_instance2": {
        "DBInstanceIdentifier": "rds-instance-2",
        "AllocatedStorage": 20,
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "MasterUsername": "username2",
        "MasterUserPassword": "password2"
    }
}
CLOUDFRONT_ID = "E351W636RW6OIT"
HOSTED_ZONE_NAME = "devorderz.com"
BUCKET_NAME = "devorderz.com"

def check_or_create_rds_instance(config):
    try:
        # Describe the RDS instance
        db_instance = rds.describe_db_instances(DBInstanceIdentifier=config["DBInstanceIdentifier"])
        assert db_instance["DBInstances"][0]["DBInstanceStatus"] == "available"
    except ClientError as e:
        # If instance not found, create it
        if e.response['Error']['Code'] == 'DBInstanceNotFound':
            print(f"Creating RDS instance '{config['DBInstanceIdentifier']}'...")
            try:
                rds.create_db_instance(**config)
                print(f"RDS instance '{config['DBInstanceIdentifier']}' creation initiated.")
            except ClientError as create_error:
                pytest.fail(f"Failed to create RDS instance '{config['DBInstanceIdentifier']}': {create_error}")
        else:
            pytest.fail(f"Error with RDS instance '{config['DBInstanceIdentifier']}': {e}")

def test_rds_instance_1_exists_or_create():
    check_or_create_rds_instance(DB_INSTANCES["rds_instance1"])

def test_rds_instance_2_exists_or_create():
    check_or_create_rds_instance(DB_INSTANCES["rds_instance2"])

def test_s3_bucket_exists():
    try:
        response = s3.head_bucket(Bucket=BUCKET_NAME)
        assert response["ResponseMetadata"]["HTTPStatusCode"] == 200
    except ClientError as e:
        pytest.fail(f"S3 Bucket check failed: {e}")

def test_route53_hosted_zone_exists():
    try:
        hosted_zones = route53.list_hosted_zones_by_name(DNSName=HOSTED_ZONE_NAME)["HostedZones"]
        print("Hosted Zones Found:", hosted_zones)
        assert any(zone["Name"].strip('.') == HOSTED_ZONE_NAME.strip('.') for zone in hosted_zones)
    except ClientError as e:
        pytest.fail(f"Route 53 hosted zone check failed: {e}")

def test_cloudfront_distribution():
    try:
        distributions = cloudfront.list_distributions()
        print("Distributions Found:", distributions["DistributionList"]["Items"])
        assert any(dist["Id"] == CLOUDFRONT_ID for dist in distributions["DistributionList"]["Items"])
    except ClientError as e:
        pytest.fail(f"CloudFront distribution check failed: {e}")

def test_cognito_user_pool_exists():
    try:
        user_pools = cognito.list_user_pools(MaxResults=10)["UserPools"]
        assert any(pool["Name"] == "project-user-pool" for pool in user_pools)
    except ClientError as e:
        pytest.fail(f"Cognito user pool check failed: {e}")
