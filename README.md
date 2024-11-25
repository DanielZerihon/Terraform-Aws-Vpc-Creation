# Terraform AWS Infrastructure Project

This Terraform project provisions an AWS environment with the following resources:

- A **VPC** with a CIDR block of `10.0.0.0/16`.
- Two **subnets** (one in `us-east-1a` and another in `us-east-1b`).
- An **Internet Gateway** to allow internet access.
- **Security Groups** allowing HTTP (port 80) and SSH (port 22) access.
- Two **EC2 instances** running Apache2, each in different subnets with a custom HTML page.
- An **Application Load Balancer (ALB)** distributing traffic between the two EC2 instances.
- An **S3 bucket** for storing data.

## Project Overview

### 1. Network Infrastructure

- **VPC (`aws_vpc`)**: A Virtual Private Cloud is created with a CIDR block of `10.0.0.0/16`.
- **Subnets (`aws_subnet`)**: Two subnets are created in different Availability Zones (`us-east-1a` and `us-east-1b`), each with a CIDR block of `/24`.
- **Internet Gateway (`aws_internet_gateway`)**: This enables internet access for instances in the VPC.
- **Route Table (`aws_route_table`)**: Configures routing to allow traffic from the instances to the internet via the Internet Gateway.

### 2. Security

- **Security Group (`aws_security_group`)**: A security group is created that allows inbound traffic on HTTP (port 80) and SSH (port 22), as well as all outbound traffic.

### 3. Compute Resources

- **EC2 Instances (`aws_instance`)**: Two EC2 instances are launched, each running Apache2 and serving a simple HTML page with dynamic content. Each instance has a unique instance ID displayed on its webpage.
- **User Data Scripts (`userdata_subnet1.sh`, `userdata_subnet2.sh`)**: These scripts are used to install Apache2 and generate HTML content for each instance.

### 4. Load Balancer

- **Application Load Balancer (`aws_lb`)**: An ALB is created to distribute HTTP traffic between the two EC2 instances.
- **Target Group (`aws_lb_target_group`)**: A target group is created to register the EC2 instances and monitor their health.
- **Listener (`aws_lb_listener`)**: A listener is configured to forward HTTP traffic (port 80) to the target group.

### 5. S3 Bucket

- **S3 Bucket (`aws_s3_bucket`)**: A simple S3 bucket named `tf-bucket-vpc-project-daniel-zerihon` is created for storing data.

## Files

### 1. `main.tf`
This file contains the main Terraform configuration, where resources such as the VPC, subnets, security groups, EC2 instances, ALB, and S3 bucket are defined.

### 2. `provider.tf`
This file specifies the provider configuration. It uses the AWS provider (`hashicorp/aws`) and sets the AWS region to `us-east-1`.

### 3. `variables.tf`
Defines the `cidr` variable used for the VPC's CIDR block (`10.0.0.0/16`).

### 4. `userdata_subnet1.sh` and `userdata_subnet2.sh`
These scripts are used to install Apache2 on EC2 instances and serve a simple HTML page with the instance's ID and a custom message for each subnet.
