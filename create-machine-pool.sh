#!/bin/bash

# Function to retrieve list and filter it
retrieve_list() {
    local node_type=$1
    rosa list instance-types | grep "$node_type"
}

# Function to display the interactive menu
display_menu() {
    local options=()
    local i=1
    echo "Metal Instance Types:"
    while IFS= read -r line; do
        echo "$i. $line"
        options+=("$line")
        ((i++))
    done < <(retrieve_list "$1")
    echo "0. Exit"
}

# Function to prompt for node type
prompt_node_type() {
    local node_type
    while true; do
        read -rp "Do you want bare [M]etal or [G]PU-enabled nodes? (M/G): " node_type_choice

        case "$node_type_choice" in
            [Mm]) node_type="metal" && break ;;
            [Gg]) node_type="accelerated" && break ;;
    	*) echo "Invalid choice. Please enter M or G." ;;
        esac
    done

    echo "$node_type"
}

# Function to prompt for number of replicas
prompt_replicas() {
    local replicas
    while true; do
        read -rp "Enter the number of replicas (0-5): " replicas

        if [[ $replicas =~ ^[0-5]$ ]]; then
            break
        else
            echo "Invalid input. Please enter a number between 0 and 5."
        fi
    done

    echo "$replicas"
}

provision_machine_pool() {
    local ec2_instance_type
    local replicas
    ec2_instance_type=$1
    replicas=$2

    # Retrieve the output of 'rosa list clusters' - skip the heading
    local cluster_list
    cluster_list=$(rosa list clusters | tail -n +2)
    echo $cluster_list

    # Count the number of lines in the output
    local num_clusters
    num_clusters=$(echo "$cluster_list" | wc -l)
    echo "Number of clusters is $num_clusters"

    # Check if there is exactly one cluster listed
    if [ "$num_clusters" -ne 1 ]; then
        echo "Error: There should be exactly one cluster listed."
        exit 1
    fi

    # Capture the cluster ID from the output
    local cluster_id
    cluster_id=$(echo "$cluster_list" | awk ' {print $1}')
    echo "Cluster ID: $cluster_id"

    # Check if cluster ID is empty or null
    if [ -z "$cluster_id" ]; then
        echo "Failed to retrieve cluster ID. Aborting."
        exit 1
    fi

    # Create machine pool using the captured cluster ID
    local machinepool
    machinepool="${ec2_instance_type//./-}-machinepool"     # Create a machine pool name using the instance type. Replace . with -
    echo "Adding the instance type $ec2_instance_type to the cluster $cluster_id. Machine pool name $machinepool"
    rosa create machinepool --cluster="$cluster_id" --name="$machinepool" --replicas=0 --instance-type="$ec2_instance_type" --disk-size=128GiB

    local choice
    read -p "Do you want to add the $replicas replica(s) of the instance type: $ec2_instance_type now? (Y/N): " choice
    if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
        # Scale up the machine pool - (demonstrating the other important ROSA command)
        echo "Setting replica count to $replicas"
        rosa edit machinepool --cluster="$cluster_id" --replicas="$replicas" --labels="custom-machine-type"="$machinepool" "$machinepool"
    fi

    rosa list machinepools --cluster="$cluster_id"
}

# Main function
main() {
    # A script to add a bare metal worker node to a ROSA cluster

    echo "Script to add a bare metal or GPU-enabed worker node to a cluster."
    echo "This script requires that you only have one ROSA cluster in your account."
    echo "Usage: ./create-machine-pool.sh [--profile=<aws-profile-name>] [--region=<aws-region>]"

    local node_type
    node_type=$(prompt_node_type)

    display_menu "$node_type"

    local chosen_instance
    read -rp "Enter your choice: " chosen_instance

    if [[ $chosen_instance -eq 0 ]]; then
        echo "Exiting..."
        exit 0
    fi

    local selection
    selection=$(retrieve_list "$node_type" | sed -n "${chosen_instance}p")

    # Extracting the first column from the selection
    local aws_instance_type
    aws_instance_type=$(echo "$selection" | awk '{print $1}')

    echo "You selected: $aws_instance_type"


    local replicas
    replicas=$(prompt_replicas)

    echo "Number of replicas: $replicas"

    provision_machine_pool "$aws_instance_type" "$replicas"
}

# Execute the main function
main


