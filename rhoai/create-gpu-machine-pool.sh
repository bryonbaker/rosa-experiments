#!/bin/bash

# A script to add a bare metal worker node to a ROSA cluster

echo "Script to add a bare metal worker node to a cluster."
echo "This script requires that you only have one ROSA cluster in your account."
echo "Usage: ./create-bm-machine-pool.sh [--profile=<aws-profile-name>] [--region=<aws-region>]"

# Retrieve the output of 'rosa list clusters' - skip the heading
cluster_list=$(rosa list clusters $1 $2 | tail -n +2)
echo $cluster_list

# Count the number of lines in the output
num_clusters=$(echo "$cluster_list" | wc -l)
echo "Number of clusters is $num_clusters"

# Check if there is exactly one cluster listed
if [ "$num_clusters" -ne 1 ]; then
    echo "Error: There should be exactly one cluster listed."
    exit 1
fi

# Capture the cluster ID from the output
cluster_id=$(echo "$cluster_list" | awk ' {print $1}')
echo "Cluster ID: $cluster_id"

# Check if cluster ID is empty or null
if [ -z "$cluster_id" ]; then
    echo "Failed to retrieve cluster ID. Aborting."
    exit 1
fi

# Display Accelerated Compute options for this region
rosa list instance-types $1 $2 | grep -i accelerate
ec2_instance_type="g4dn.12xlarge"   # Update this based off what is available

# Create machine pool using the captured cluster ID
# Set the replicas to zero to create a machine pool with no instances.
echo "Adding the bare metal instance type $ec2_instance_type to the cluster $cluster_id."
rosa create machinepool --cluster="$cluster_id" $1 $2 --name="gpu-machinepool" --labels="my-machine-type"="gpu" --replicas=0 --instance-type="$ec2_instance_type" --disk-size=128GiB

read -p "Do you want to add the $ec2_instance_type replica now? (Y/N): " choice
if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
    # Scale up the machine pool - (demonstrating the other important ROSA command)
    # c5.metal is a BIG and expensive machine so only add one replica
    rosa edit machinepool --cluster="$cluster_id" $1 $2 --replicas=1 gpu-machinepool
fi

rosa list machinepools --cluster="$cluster_id" $1 $2
