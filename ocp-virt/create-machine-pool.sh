#!/bin/bash

# Retrieve the output of 'rosa list clusters' - skip the heading
cluster_list=$(rosa list clusters | tail -n +2)
echo $cluster_list

# Count the number of lines in the output
num_clusters=$(echo "$cluster_list" | wc -l)
echo "Number of clusters is " $num_clusters

# Check if there is exactly one cluster listed
if [ "$num_clusters" -ne 1 ]; then
    echo "Error: There should be exactly one cluster listed."
    exit 1
fi

# Capture the cluster ID from the output
cluster_id=$(echo "$cluster_list" | awk ' {print $1}')
echo "Cluster ID: " $cluster_id

# Check if cluster ID is empty or null
if [ -z "$cluster_id" ]; then
    echo "Failed to retrieve cluster ID. Aborting."
    exit 1
fi

# Create machine pool using the captured cluster ID
# Set the replicas to zero to create a machine pool with no instances.
rosa create machinepool --cluster="$cluster_id" --name="bare-metal-machinepool" --replicas=0 --instance-type=c5.metal --disk-size=128GiB

# Scale up the machine pool - (demonstrating the other important ROSA command)
rosa edit machinepool --cluster="$cluster_id" --replicas=2 --labels="my-type"="metal" bare-metal-machinepool
