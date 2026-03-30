# 🚀 Day 4: Scalable Web Application on AWS with Terraform

##  Overview
On Day 4 of my Terraform Challenge, I built a **highly available and scalable web application infrastructure** on AWS using Terraform.

This project moves beyond a single-server setup to a **production-like architecture** using:
- Auto Scaling Group (ASG)
- Application Load Balancer (ALB)
- Multi-AZ deployment

---

##  Architecture

Users (Internet)
↓
Application Load Balancer (ALB)
↓

| | |
EC2 EC2 EC2
Instances (Auto Scaling Group)


---

##   Key Features

-   **High Availability**: Instances deployed across multiple Availability Zones  
-   **Scalability**: Auto Scaling Group automatically adjusts capacity  
-   **Load Balancing**: Traffic distributed evenly using ALB  
-   **Infrastructure as Code**: Fully managed using Terraform  
-   **Automated Setup**: EC2 instances configured with user data (Apache + GitHub repo)

---

##  Technologies Used

- **Terraform**
- **AWS EC2**
- **AWS VPC**
- **Application Load Balancer**
- **Auto Scaling Group**
- **Linux (Ubuntu)**
- **Apache Web Server**

---

##  Deployment Details

### Terraform Output
alb_dns_name = web-alb-500253292.us-east-1.elb.amazonaws.com

###  Access Application
http://web-alb-500253292.us-east-1.elb.amazonaws.com

---

##   Project Structure
.
├── main.tf
├── variables.tf
├── outputs.tf
├── user_data.sh
└── README.md


---

##   Challenges & Lessons Learned

During this project, I encountered and resolved several real-world issues:

-   ALB not accessible due to wrong security group attachment  
-   502/503 errors from misconfigured target group  
-   Timeout issues due to blocked inbound traffic  
-   Launch template error caused by missing key pair  
-   Subnet and routing misconfigurations  

###   Key Learnings:
- Security groups must be correctly attached to resources  
- ALB and EC2 communication must be explicitly allowed  
- Health checks are critical for load balancing  
- Debugging is essential in cloud engineering  

---

##   How It Works (Simple Explanation)

1. Users access the app via the ALB  
2. ALB distributes traffic across EC2 instances  
3. Auto Scaling Group ensures:
   - New instances are created when needed  
   - Failed instances are replaced automatically  

---

##   How to Run This Project

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd <repo-folder>
```

terraform init
terraform plan
terraform apply
terraform destroy

##  Final Thoughts

This project helped me transition from a basic setup to a scalable, production-style infrastructure.

It reinforced that:

DevOps is not just about building — it's about debugging, understanding systems, and improving continuously.

### Let's Connect

If you're learning Terraform or cloud engineering, feel free to connect and share ideas!

##  #Terraform #AWS #DevOps #InfrastructureAsCode #CloudEngineering #30DayTerraformChallenge