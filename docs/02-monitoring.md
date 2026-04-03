Monitoring and Logging Architecture

Overview

The cluster uses a dedicated monitoring node deployed in the public subnet within the 10.0.1.x range. This node is responsible for collecting, processing and visualizing logs and metrics from all private cluster components including controller nodes, compute nodes and storage systems.

This design ensures centralized observability while maintaining isolation of the core HPC infrastructure.

Logging using Elastic Stack

The Elastic Stack is implemented to provide centralized logging across the cluster. It enables collection, processing, storage and visualization of system logs in a unified platform.

Components

Elasticsearch stores indexed log data and listens on port 9200. It is configured to accept connections on all network interfaces.

Logstash acts as the log processing pipeline. It receives logs on port 5044 and processes system log data using parsing filters to extract structured information.

Kibana provides a web based interface for log visualization and analysis. It is accessible through a browser using the public IP address of the monitoring node on port 5601.

Filebeat is installed on all nodes including controllers, compute nodes and storage systems. It reads local system logs and forwards them to Logstash on the monitoring node.

Configuration Details

Logstash input is configured to accept log data using the Beats protocol on port 5044.

Logstash output sends processed logs to Elasticsearch using time based indexing. Indices are created in a daily format to support efficient querying and retention.

Filebeat output is configured to forward logs to the monitoring node using the defined hostname and port 5044.

Infrastructure Monitoring using Zabbix

Zabbix is deployed to monitor the health and performance of all cluster components. The Zabbix server runs on the monitoring node and acts as the central monitoring system.

Zabbix agents are installed on all private nodes including controllers, compute nodes and storage systems. These agents collect metrics such as CPU usage, memory utilization, disk activity and network performance.

The monitoring system is configured to detect node failures and performance issues. Alerts are triggered when nodes become unreachable or when defined thresholds are exceeded.

This monitoring layer complements the compute recovery mechanism by providing visibility and proactive alerting.

Network Access and Security Configuration

Access to monitoring and logging services is controlled through a dedicated security group associated with the monitoring node.

Security Group Name SG Monitoring Public  

Allowed Ports

Port 5601 is used to access the Kibana dashboard for log visualization.  
Port 80 and 443 are used for accessing the Zabbix web interface.  
Port 5044 is used for receiving log data from Filebeat agents.  
Port 10051 is used for communication between Zabbix agents and the Zabbix server.  

These configurations ensure that only required traffic is allowed while maintaining secure access to observability services.

Summary

This architecture provides centralized logging and monitoring for the HPC cluster. The Elastic Stack enables detailed log analysis while Zabbix provides real time infrastructure monitoring and alerting. Together they ensure visibility, reliability and operational awareness across all layers of the system.
