# HaifaMix: High-Availability Multi-Tier AWS Architecture
![Status](https://img.shields.io/badge/Status-Verified--Healthy-success)
![AWS](https://img.shields.io/badge/Provider-AWS-232F3E?logo=amazon-aws)
![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform)

## 📌 Project Overview
A production-grade, three-tier web architecture deployed using **Infrastructure as Code (Terraform)**. This project demonstrates high availability, secure VPC design, and automated CI/CD pipelines, verified through local Phoenix homelab testing.

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
[LinkedIn](https://www.linkedin.com/in/HaifaAlanesi) | [Website](https://haifa.work)
