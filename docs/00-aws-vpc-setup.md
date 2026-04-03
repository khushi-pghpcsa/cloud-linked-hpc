AWS VPC and Network Architecture

VPC Configuration

VPC Name HPC VPC  
IPv4 CIDR Block 10.0.0.0/16  

The Virtual Private Cloud provides an isolated networking environment for the HPC cluster. It enables secure communication between all components including controller nodes, compute nodes, storage systems and monitoring services.

Overlay IP Configuration

An overlay IP is used to enable high availability for the controller layer. This IP acts as a floating endpoint that can move between controller nodes during failover events.

Overlay IP Address 192.168.2.50  
CIDR 192.168.2.50/32  

This IP is defined outside the VPC CIDR range to avoid conflicts with internal subnets and to allow controlled routing through the AWS route table.

Route Table Configuration

A static route must be created in the private route table to associate the overlay IP with the active controller node.

Destination 192.168.2.50/32  
Target Instance ID of Controller 1  

During normal operation, the overlay IP is mapped to Controller 1. In case of failure, Pacemaker automatically updates the route table and redirects traffic to Controller 2.

This ensures uninterrupted service availability without manual intervention.

Security Group Configuration

The internal cluster security group must allow traffic originating from the overlay IP.

Security Group Name SG Cluster Internal  

Rule Configuration

Traffic Type All Traffic  
Source 192.168.2.50/32  
Description Allows communication via overlay IP  

This configuration ensures that all cluster nodes can communicate using the floating IP regardless of which controller node is active.

Summary

This network design enables high availability for controller nodes using a floating IP mechanism. It provides controlled routing, seamless failover and secure communication within the HPC cluster environment.
