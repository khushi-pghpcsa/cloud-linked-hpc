import boto3
import time
import logging

"""
AWS Compute Node Recovery Agent

Monitors the health of a primary compute instance and automatically
starts a standby instance if the primary becomes unhealthy.

Author: Your Name
"""

# =========================
# Configuration
# =========================
REGION = "us-east-1"

PRIMARY_INSTANCE_ID = "i-xxxxxxxxxxxxxxxxx"   # Replace with Compute-1 Instance ID
STANDBY_INSTANCE_ID = "i-yyyyyyyyyyyyyyyyy"   # Replace with Compute-2 Instance ID

CHECK_INTERVAL = 30  # seconds

# =========================
# Logging Setup
# =========================
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s"
)
logger = logging.getLogger(__name__)

# AWS EC2 Client
ec2 = boto3.client("ec2", region_name=REGION)


# =========================
# Health Check Function
# =========================
def check_health(instance_id):
    """
    Check the state and system health of an EC2 instance.

    Returns:
        (state, status) -> tuple(str, str)
    """
    try:
        response = ec2.describe_instance_status(
            InstanceIds=[instance_id],
            IncludeAllInstances=True
        )

        if not response["InstanceStatuses"]:
            return "stopped", "unknown"

        instance_info = response["InstanceStatuses"][0]

        state = instance_info["InstanceState"]["Name"]
        status = instance_info["InstanceStatus"]["Status"]

        return state, status

    except Exception as error:
        logger.error(f"Error checking instance health: {error}")
        return "error", "error"


# =========================
# Failover Logic
# =========================
def trigger_failover():
    """
    Start standby instance when primary fails.
    """
    logger.warning("Primary compute node failure detected. Initiating failover...")

    try:
        # Start standby instance
        ec2.start_instances(InstanceIds=[STANDBY_INSTANCE_ID])
        logger.info(f"Starting standby instance: {STANDBY_INSTANCE_ID}")

        # Wait until instance is running
        waiter = ec2.get_waiter("instance_running")
        waiter.wait(InstanceIds=[STANDBY_INSTANCE_ID])

        logger.info("Failover complete. Standby node is now active.")

    except Exception as error:
        logger.error(f"Failover failed: {error}")


# =========================
# Monitoring Loop
# =========================
def monitor():
    """
    Continuously monitor primary instance health.
    """
    logger.info("Recovery agent started. Monitoring primary compute node...")

    failover_triggered = False

    while True:
        state, health = check_health(PRIMARY_INSTANCE_ID)

        logger.info(f"Primary Node Status | State: {state} | Health: {health}")

        if not failover_triggered and (state != "running" or health != "ok"):
            trigger_failover()
            failover_triggered = True
            break

        time.sleep(CHECK_INTERVAL)


# =========================
# Entry Point
# =========================
if __name__ == "__main__":
    monitor()
