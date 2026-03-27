# HaifaMix: High-Availability Multi-Tier AWS Architecture
![Status](https://img.shields.io/badge/Status-Verified--Healthy-success)
![AWS](https://img.shields.io/badge/Provider-AWS-232F3E?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)

## 📌 Project Overview
This project demonstrates a production-grade, three-tier web architecture deployed on AWS. The infrastructure is fully automated using Terraform, focusing on high availability, security isolation, and scalable data persistence. It bridges enterprise database management with modern cloud-native orchestration.
<img width="1408" height="768" alt="final-multi-terir" src="https://github.com/user-attachments/assets/f748bf62-802f-49ed-abb1-1c587eae261c" />

🏗️ Architecture Design
The infrastructure is partitioned into several layers to ensure maximum security and fault tolerance:

Networking Layer: A custom VPC with Public Subnets for the Load Balancer and Private Subnets for application and database tiers.

Compute Layer: Auto-scaling EC2 instances managed by an Application Load Balancer (ALB).

Storage Layer: A Multi-AZ Amazon RDS (PostgreSQL/SQL Server) instance for automated failover and data integrity.

Security Layer: Integrated AWS CloudFront for global content delivery and security groups configured with the principle of least privilege.

🛠️ Tech Stack
Provider: AWS (EC2, VPC, RDS, S3, ALB, CloudFront)

IaC: Terraform

OS: Ubuntu Linux

Database: Amazon RDS

🚀 Key Features & Implementation
Zero-Inbound Exposure: All application and database nodes are housed in private subnets; external access is strictly managed via the ALB and CloudFront.

Multi-AZ Resilience: The architecture spans multiple Availability Zones to ensure 99.9% uptime.

Database Reliability: Leveraging my background as a DBA, I implemented an RDS configuration with automated snapshots and multi-region readiness.

Validation: Verified end-to-end connectivity via synthetic load testing and CloudWatch monitoring.


## 🏗️ Architecture Features
* **VPC Networking:** Public/Private subnet isolation with a verified Internet Gateway (IGW) and custom Route Tables.
* **High Availability:** Application Load Balancer (ALB) distributing traffic across multiple Availability Zones.
* **Auto-Scaling:** Self-healing EC2 fleet (t2.micro) running Apache/PHP.
* **Database Security:** RDS MySQL instance isolated in a private DB Subnet Group.
* **Content Delivery:** Integrated with CloudFront for global edge caching and GoDaddy DNS integration.

## 🛠️ Tech Stack
* **IaC:** Terraform
* **Compute:** Amazon EC2 (Amazon Linux 2023)
* **Networking:** VPC, ALB, IGW, NAT Gateway
* **Database:** Amazon RDS (MySQL)
* **Automation:** GitHub Actions for automated code deployment

## 🧠 Key Troubleshooting Wins (The "DevOps" Journey)
* **The "Smoking Gun" (IGW Routing):** Identified a `504 Gateway Timeout` caused by missing Route Table associations for the Public Subnets. Resolved by mapping `0.0.0.0/0` to the Internet Gateway, enabling the ALB to communicate with the internet.
* **Target Group Health:** Successfully moved Target Group status from "Unhealthy/Initial" to **Healthy (200 OK)** by aligning Security Group rules and VPC routing logic.
* **GitOps Flow:** Implemented an automated deployment pipeline to bridge the local repository with the live AWS environment.

## 🚀 How to Deploy
1. Initialize Terraform: `terraform init`
2. Review Plan: `terraform plan`
3. Deploy Infrastructure: `terraform apply`
4. Verify Connectivity: `curl -I http://[ALB-DNS-NAME]/index.php`

---
*Note: This project was built for educational purposes and destroyed after verification to follow AWS cost-optimization best practices.*
 
www.linkedin.com/in/haifa-alanesi
