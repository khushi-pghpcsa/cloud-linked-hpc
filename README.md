Cloud Linked HPC – High Performance Computing Cluster on AWS

Project Overview

Cloud Linked HPC is a cloud based High Performance Computing cluster deployed on AWS using Ubuntu 22.04.5 LTS.

The project demonstrates the design and implementation of a secure, scalable and highly available HPC infrastructure integrating workload management, distributed storage, centralized authentication and monitoring systems.

The objective of this project is to simulate an enterprise level HPC environment with proper network segmentation, failover mechanisms and automation.

Architecture Overview

The infrastructure is deployed inside an AWS Virtual Private Cloud and divided into two logical segments.

Public Subnet

Login Node  
LDAP Server for centralized authentication  
ELK Stack for log management and analysis  
Zabbix for infrastructure monitoring  

Private Subnet

Controller Node 1 with SLURM and PCS  
Controller Node 2 with SLURM and PCS  
Compute Nodes for workload execution  
BeeGFS Storage Node for distributed file system  

Private subnet components are isolated from direct internet access to ensure secure internal communication.

Core Components Configured

High Availability

Pacemaker version 2.1.2  
PCS version 0.10.11  
Corosync version 3.1.6  

Controller nodes are configured in high availability mode with automatic failover capability.

Workload Management

SLURM Workload Manager is used for job scheduling, resource allocation, node management and partition configuration.

Distributed Storage

BeeGFS version 8.2.2 is configured as a parallel distributed file system providing shared storage access, high throughput and concurrent read and write operations across compute nodes.

Centralized Authentication

LDAP server is implemented to provide centralized user authentication and consistent access control across the cluster.

Monitoring and Logging

ELK Stack consisting of Elasticsearch, Logstash and Kibana is used for log collection, processing and visualization.

Zabbix monitoring server is used to track infrastructure health including CPU usage, memory utilization, disk activity and node availability.

A Python based monitoring script is implemented to validate SLURM services, BeeGFS services, disk usage and overall node health.

Automation

Shell based automation scripts are developed to deploy and configure all components of the cluster.

Automation includes login node setup, controller configuration, SLURM installation, compute node provisioning and BeeGFS deployment.

This approach ensures reproducibility, consistency and reduced manual intervention.

Repository Structure

architecture contains system design and architecture diagrams  
configs contains configuration files for SLURM, Corosync, BeeGFS, ELK and LDAP  
scripts contains automation scripts for deployment  
monitoring contains Python based health check scripts  
screenshots contains validation outputs and dashboards  
docs contains detailed setup and configuration documentation  

Scope of the Project

This project demonstrates deployment of an HPC cluster in a cloud environment, implementation of high availability for controller nodes, integration of distributed storage, secure network segmentation, centralized authentication, monitoring and logging integration and infrastructure automation.

The architecture is designed to be scalable and can be extended to support larger workloads and advanced computing use cases.

Conclusion

Cloud Linked HPC represents a production oriented HPC deployment model combining high availability, distributed storage, workload management and centralized monitoring within a secure AWS based infrastructure.
