HA Cluster Setup Guide

Controller High Availability using Pacemaker and Corosync

Pacemaker and Corosync are installed on both controller nodes to provide high availability. These components manage cluster communication, resource allocation and failover operations.

Cluster authentication is configured using the hacluster user across all controller nodes. Proper password synchronization is required before initializing the cluster.

Since the architecture uses a two node cluster, quorum enforcement is disabled to prevent unnecessary service disruption during node failure.

Resource Configuration

A virtual IP resource is configured to act as a floating endpoint between controller nodes. This ensures that services remain accessible regardless of which controller node is active.

Resource Agent ocf heartbeat aws vpc move ip  
Virtual IP Address 192.168.2.50  
Network Interface enp39s0  
AWS Region us east 1  

The resource agent dynamically updates the AWS route table to shift the virtual IP between controllers during failover, ensuring uninterrupted service availability.

BeeGFS Distributed Storage Setup

BeeGFS is deployed to provide a high performance parallel file system for the HPC environment. The architecture separates management, metadata and client services to ensure scalability and performance.

Management Service Node 10.0.2.20  
Metadata Service Node 10.0.2.20  
Client Service installed on all controller and compute nodes  

Authentication is configured using a shared secret file named conn.auth. This file is securely generated and distributed to all nodes under the etc beegfs directory to enable trusted communication between services.

Slurm Workload Manager Configuration

Slurm is deployed as the workload manager to handle job scheduling, resource allocation and node orchestration.

Version 20.11.9  
Installation Method compiled from source  

Authentication is implemented using Munge. A common Munge key is generated and distributed across controller and compute nodes to enable secure communication.

Database configuration is implemented using MariaDB with slurmdbd enabled for job accounting and tracking.

Binary paths are configured by exporting the Slurm installation directory to the system path. The primary binary location is slurm dir slurm 20.11.9 bin.

AWS Based Compute Node Recovery

Compute node resiliency is handled using a custom recovery mechanism implemented through AWS APIs.

A Python based recovery agent uses the boto3 library to monitor the health status of the primary compute node.

If the primary compute node fails AWS status checks, the recovery agent automatically triggers the AWS API to start the standby compute node.

This mechanism ensures minimal disruption to workloads and provides an additional layer of fault tolerance.

The recovery script is located at configs aws recovery recovery agent dot py.

Summary

This configuration establishes a resilient HPC control plane with automated failover for both controller and compute layers. Pacemaker manages controller failover through route table updates, while the recovery agent ensures compute node availability. BeeGFS provides distributed storage and Slurm enables efficient workload management across the cluster.
