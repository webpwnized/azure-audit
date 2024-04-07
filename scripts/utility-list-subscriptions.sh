#!/bin/bash

# Source common constants and functions
source ./common-constants.inc
source ./functions.inc

# Output header based on CSV flag
function output_header() {
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"MEMBERS\""
}

# Output subscription information
function output_subscription() {
    if [[ $SUBSCRIPTION_NAME != "Visual Studio"* ]]; then
        output_subscription_helper
    fi
}

# Determine output format and call appropriate function
function output_subscription_helper() {
    if [[ $CSV == "True" ]]; then
        output_subscription_csv
    else
        output_subscription_text
    fi
}

# Output subscription information in CSV format
function output_subscription_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$MEMBERS\""
}

# Output subscription information in text format
function output_subscription_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Members: $MEMBERS"
    echo $BLANK_LINE
}

# Parse subscription information
function parse_subscription() {
    SUBSCRIPTION_NAME=$(echo $SUBSCRIPTION | jq -rc '.displayName')
    SUBSCRIPTION_STATE=$(echo $SUBSCRIPTION | jq -rc '.state')
    SUBSCRIPTION_ID=$(echo $SUBSCRIPTION | jq -rc '.subscriptionId')
}

# Process role assignments
function process_role_assignments() {
    declare -A unique_members  # Declare an associative array to store unique members
    
    while IFS='' read -r ROLE_ASSIGNMENT; do
        PRINCIPLE_TYPE=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.principalType')

        if [[ $PRINCIPLE_TYPE == "User" ]]; then
            PRINCIPLE_NAME=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.principalName')
            unique_members["$PRINCIPLE_NAME"]=1  # Store unique user in the associative array
        elif [[ $PRINCIPLE_TYPE == "Group" ]]; then
            GROUP_NAME=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.principalName')
            ROLE=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.roleDefinitionName')
            GROUP_MEMBERS=$(get_group_members_serialized "$GROUP_NAME")

            # Split group members and add unique members to the associative array
            IFS=';' read -ra members_array <<< "$GROUP_MEMBERS"
            for member in "${members_array[@]}"; do
                unique_members["$member"]=1
            done
        fi   
    done <<< "$(echo "$1" | jq -rc '.[]')"

    # Concatenate unique members from the associative array
    MEMBERS=""
    for member in "${!unique_members[@]}"; do
        MEMBERS+="$member;"
    done
}


# Source common menu
source ./common-menu.inc

# Get subscriptions
SUBSCRIPTIONS=$(get_subscriptions $p_SUBSCRIPTION_ID)

# Debugging information
if [[ $DEBUG == "True" ]]; then
    echo "Subscriptions (JSON): $SUBSCRIPTIONS"
fi

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS != "[]" ]]; then
    output_header

    # Iterate through each subscription
    echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
        parse_subscription

        # Get role assignments and store in a variable
        ROLE_ASSIGNMENTS=$(get_subscription_role_assignments "$SUBSCRIPTION_NAME")

        # Process role assignments
        process_role_assignments "$ROLE_ASSIGNMENTS"

        output_subscription
    done
else
    echo "No subscriptions found"
    echo $BLANK_LINE
fi


