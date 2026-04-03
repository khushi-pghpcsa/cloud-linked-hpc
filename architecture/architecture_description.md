# Cloud-Linked HPC Architecture

## Overview

This project implements a cloud-based High Performance Computing (HPC) cluster on AWS, designed to provide scalability, high availability, and centralized system management.

The architecture integrates workload scheduling, distributed storage, centralized authentication, and monitoring/logging systems to simulate a production-grade HPC environment.


## Network Architecture

The infrastructure is deployed within an AWS Virtual Private Cloud (VPC) using the CIDR block 10.0.0.0/16.

* Public Subnet: Hosts the login node and monitoring services.
* Private Subnet: Hosts controller nodes, compute nodes, and storage services.

A key design feature is the use of an overlay IP (192.168.2.50), which enables seamless failover between controller nodes. The AWS route table is dynamically updated during failover events to redirect traffic to the active controller.


## Core Components

### High Availability Controllers

The system uses two controller nodes configured in an active-passive setup:

* controller-1 (active)
* controller-2 (standby)

High availability is managed using Pacemaker and Corosync. In the event of failure, cluster services are automatically migrated to the standby node by updating the route table.


### SLURM Workload Manager

SLURM is used as the workload manager to schedule and distribute jobs across compute nodes. It operates on a queue-based model and ensures efficient resource allocation and job execution.


### Compute Nodes

Compute nodes are responsible for executing HPC workloads. A Python-based recovery mechanism using AWS Boto3 is implemented to monitor node health and automatically start a standby compute node in case of failure.


### BeeGFS Distributed Storage

BeeGFS is deployed as a parallel distributed file system to provide high-performance data access across all nodes. It consists of management, metadata, and storage services, enabling efficient parallel I/O operations.


### LDAP Authentication

LDAP is used for centralized authentication and user management. It ensures consistent access control across login nodes, compute nodes, and system services.


## Monitoring and Logging

# ELK Stack

The ELK stack is used for centralized logging:

* Filebeat collects logs from all nodes
* Logstash processes and parses logs
* Elasticsearch stores indexed log data
* Kibana provides visualization and analysis

# Zabbix

Zabbix is used for infrastructure monitoring. It tracks system metrics such as CPU, memory, and network usage, and generates alerts when nodes become unavailable.


High Availability Workflow

1. The active controller node handles all incoming requests.
2. If the active node fails, Pacemaker detects the failure.
3. The AWS route table is updated to redirect traffic to the standby controller.
4. The standby node becomes active without manual intervention.

This ensures minimal downtime and continuous service availability.


Job Execution Flow

1. The user connects to the system through the login node.
2. Jobs are submitted to the SLURM scheduler.
3. SLURM assigns jobs to available compute nodes.
4. Compute nodes execute the workloads.
5. Data is accessed and stored through the BeeGFS distributed file system.


Monitoring and Logging Flow

* System logs are collected by Filebeat and sent to Logstash.
* Logstash processes the data and forwards it to Elasticsearch.
* Kibana is used to visualize and analyze logs.
* Zabbix agents collect system metrics and report to the Zabbix server for monitoring and alerting.


Security Features

* Isolation of resources using private subnets
* Controlled access through AWS security groups
* Centralized authentication via LDAP
* Internal communication managed through overlay IP mechanisms


Key Highlights

* High availability cluster with automated failover
* Scalable and distributed architecture
* Centralized monitoring and logging
* Automated recovery mechanisms for compute nodes
* Cloud-native design leveraging AWS services


Conclusion

This architecture represents a production-grade HPC system that combines fault tolerance, scalability, and observability. It demonstrates the practical implementation of distributed computing concepts using cloud infrastructure and modern DevOps practices.
