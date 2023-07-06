#!/bin/bash

regions=("us-east-1" "us-west-2" "eu-central-1" "eu-west-1", "us-east-2")

csv_file="public_ips.csv"
for region in "${regions[@]}"; do
    echo "Checking region: $region"

    # Get a list of EC2 instances with public IPs
    instance_info=$(aws ec2 describe-instances --region "$region" \
        --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[?not_null(PublicIpAddress)].{Instance:InstanceId, PublicIP:PublicIpAddress}' \
        --output text)

    # Process the instance information
    if [[ -n "$instance_info" ]]; then
        echo "Found instance(s) with public IP(s) in $region."

        # Append to the CSV file
        while read -r line; do
            instance_id=$(echo "$line" | awk '{print $1}')
            public_ip=$(echo "$line" | awk '{print $2}')
            echo "$region,$instance_id,$public_ip" >> "$csv_file"
        done <<< "$instance_info"
    else
        echo "No instances with public IPs found in $region."
    fi
done

echo "Script execution complete."
