# Food Distribution Application

## Overview

The Food Distribution Application is a cloud-based solution designed to efficiently manage and distribute food resources. Utilizing AWS services, this application ensures scalability, reliability, and security to support food distribution operations.

## Features

- **Scalable Infrastructure:** Deployed on AWS using Terraform for Infrastructure as Code (IaC), facilitating easy scaling and management.
- **Automated Workflows:** Uses AWS Step Functions and Lambda for automating order processing and inventory management.
- **Database Integration:** Connects to an RDS database for secure and efficient data management.
- **Secure Access:** Implements IAM roles and policies, S3 bucket policies, and encryption to ensure data protection.
- **Efficient Monitoring:** Integrated with AWS CloudWatch for performance monitoring and AWS CloudTrail for logging API activity.
- **Notification and Queue Management:** Utilizes AWS SNS for notifications and SQS for message queuing to handle asynchronous tasks.

## Architecture

- **Frontend:** React-based user interface.
- **Backend:** Serverless architecture with AWS Lambda functions.
- **Database:** Managed RDS instance for data storage.
- **Infrastructure:** Managed through Terraform, including VPCs, NAT gateways, and security groups.
- **Storage:** S3 buckets with configured bucket policies for secure data storage.
- **Monitoring and Logging:** AWS CloudWatch for real-time monitoring, CloudTrail for logging API calls, and SQS/SNS for handling asynchronous tasks.

## Getting Started

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/yourusername/food-distribution-app.git


Infrastructure Setup
This project leverages Terraform to manage and deploy cloud infrastructure on AWS. The infrastructure is designed to support a secure and scalable environment for a food delivery service, focusing on database management and network configuration.

Network Configuration
VPC (Virtual Private Cloud):
A custom VPC with a CIDR block of 10.0.0.0/16 has been created to isolate and manage network resources.
Two private subnets have been provisioned across different availability zones (us-east-2a and us-east-2b) to ensure high availability for the database instances.
RDS Security Group
RDS Security Group:
A security group has been set up to control access to the RDS instances.
The group allows inbound traffic on port 3306 for MySQL database access and on port 22 for SSH access.
Outbound traffic is unrestricted to allow the instances to communicate with external resources as needed.
The security group is applied to both RDS instances to ensure consistent security policies.
RDS Instances
Database Instances:
Two MySQL RDS instances (db.t3.micro) have been provisioned in the private subnets.
The instances are configured with the appropriate usernames and passwords, which are securely managed using Terraform variables marked as sensitive.
Skip final snapshot is set to false to ensure data is preserved during instance termination.
Outputs
RDS Endpoints:
The Terraform configuration outputs the endpoints for both RDS instances, which can be used to connect the application to the databases.
Security Group ID:
The security group ID is also output, allowing for easy reference in other modules or configurations.
Variables
Flexible Configuration:
Terraform variables have been defined for key parameters such as database names, credentials, subnet IDs, and security group IDs.
This allows for easy customization and deployment in different environments.
Deployment Instructions
Initialize Terraform:

Run terraform init in the root directory to initialize the Terraform environment and download necessary providers.
Plan and Apply:

Use terraform plan to review the changes that will be applied to your AWS environment.
Run terraform apply to deploy the infrastructure. Make sure to review the plan and confirm the changes.
Access Outputs:

After deployment, use terraform output to view the RDS endpoints and security group ID.
