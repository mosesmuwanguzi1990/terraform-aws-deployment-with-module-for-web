# Terraform Networking Project

This project provisions a complete **VPC networking setup** and deploys a simple web application on AWS using Terraform.

---

## 📌 Infrastructure Overview

- **Region**: `us-east-1`
- **VPC Setup**:
  - 2 **Public Subnets**  
    - `us-east-1a`  
    - `us-east-1b`
  - 2 **Private Subnets**  
    - `us-east-1a`  
    - `us-east-1b`

---

## 🌐 Networking Design

- **Application Load Balancer (ALB)**  
  - Deployed across the **public subnets** in both availability zones.  
  - Routes traffic to target EC2 instances in private subnets.

- **Target Group (EC2 Instances)**  
  - Runs in **private subnets** across two availability zones.  
  - Ensures **high availability** and fault tolerance.

---

## 💻 Compute Setup

- **Launch Template**  
  - Defines EC2 configuration (AMI, instance type, security groups, and user data).

- **Auto Scaling Group (ASG)**  
  - Ensures the desired number of EC2 instances are always running.  
  - Distributes instances across private subnets in multiple AZs.

- **EC2 Instances**  
  - Apache Web Server installed via **user data script**.  
  - Configured with **SSL** for secure access.  

---

## ✅ Key Features
- Highly available multi-AZ architecture.  
- Public-facing ALB with secure traffic handling.  
- Private EC2 instances (not directly exposed to the internet).  
- Automated scaling with ASG.  
- Apache web server configured with SSL.

---
