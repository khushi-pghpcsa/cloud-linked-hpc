Cloud Linked HPC – High Performance Computing Cluster on AWS

Overview
Cloud Linked HPC is a cloud-based High Performance Computing (HPC) cluster deployed on AWS using Ubuntu 22.04.5 LTS. The project focuses on designing and implementing a secure, scalable, and highly available HPC infrastructure by integrating workload management, distributed storage, centralized authentication, and monitoring systems.

The primary objective is to simulate an enterprise-grade HPC environment with proper network segmentation, failover mechanisms, and automation practices.


System Architecture
The infrastructure is deployed within an AWS Virtual Private Cloud (VPC) and is divided into two logical network segments to ensure security and operational efficiency.

Public Subnet
The public subnet hosts externally accessible services and management components:

- Login Node for user access
- LDAP Server for centralized authentication
- ELK Stack for log management and analysis
- Zabbix Server for infrastructure monitoring

Private Subnet
The private subnet contains internal HPC components isolated from direct internet access:

- Controller Nodes configured with SLURM and PCS
- Compute Nodes for parallel workload execution
- BeeGFS Storage Node for distributed file system operations

This segmentation ensures secure communication and restricts exposure of critical components.


Core Components

High Availability
The controller nodes are configured in a high-availability setup using Pacemaker, PCS, and Corosync. This enables automatic failover and ensures uninterrupted cluster operations in case of node failure.

Workload Management
SLURM is used as the workload manager to handle job scheduling, resource allocation, node management, and partition configuration. It enables efficient execution of parallel workloads across compute nodes.

Distributed Storage
BeeGFS is implemented as a parallel distributed file system, providing high throughput and concurrent read/write capabilities. It allows all compute nodes to access shared storage efficiently.

Centralized Authentication
LDAP is used to manage centralized authentication, ensuring consistent user access control across all nodes in the cluster.

Monitoring and Logging
The system integrates ELK Stack and Zabbix for comprehensive monitoring and logging:

- ELK Stack handles log aggregation, processing, and visualization
- Zabbix monitors system performance and infrastructure health

A Python-based monitoring script is used to validate key system parameters, including SLURM services, BeeGFS services, disk utilization, and node health status.


Automation
The infrastructure setup is automated using shell scripts to ensure reproducibility and consistency. Automation covers:

- Login node configuration
- Controller node setup
- SLURM installation and configuration
- Compute node provisioning
- BeeGFS deployment

This approach reduces manual intervention and minimizes configuration errors.


Repository Structure
The repository is organized to reflect a modular and maintainable design:

- architecture/ contains system and network design artifacts
- automation/ includes shell scripts for deployment and setup
- configs/ stores configuration files for services such as SLURM, Corosync, BeeGFS, ELK, and LDAP
- monitoring/ includes Python scripts for system health checks
- screenshots/ contains validation outputs and dashboards
- docs/ provides detailed setup and configuration documentation



Scope
This project demonstrates the deployment of an HPC cluster in a cloud environment with a focus on:

- High availability configuration
- Parallel workload execution
- Distributed storage integration
- Secure network segmentation
- Centralized authentication
- Monitoring and logging integration
- Infrastructure automation

The architecture is designed to be scalable and can be extended to support larger workloads and advanced research applications.


Conclusion
Cloud Linked HPC represents a production-oriented approach to deploying high-performance computing infrastructure on the cloud. By combining high availability, distributed storage, workload management, and monitoring within a secure AWS environment, the project reflects real-world HPC system design principles.

# cloud-linked-hpc
An HPC architecture integrated with cloud infrastructure to deliver high availability, parallel computation, and real-time performance monitoring.

