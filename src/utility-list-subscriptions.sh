#!/bin/bash

# Debug: ./utility-list-subscriptions.sh --subscription 651b4cdc-83bc-466a-975d-df1a9c2be5b1

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

function parse_subscription() {
    # Parse subscription information from JSON
    SUBSCRIPTION_NAME=$(jq -rc '.displayName // empty' <<< "$SUBSCRIPTION")
    SUBSCRIPTION_STATE=$(jq -rc '.state // empty' <<< "$SUBSCRIPTION")
    SUBSCRIPTION_ID=$(jq -rc '.subscriptionId // empty' <<< "$SUBSCRIPTION")
}

function get_role_assignments() {
    # Get role assignments and store in a variable
    ROLE_ASSIGNMENTS=$(get_subscription_role_assignments "$SUBSCRIPTION_NAME")
}

# Function to get and process role assignments
function parse_role_assignments() {
    
    # Initialize associative array to store unique members
    declare -A unique_members

    # Iterate through each role assignment using a while loop
    while IFS='' read -r ROLE_ASSIGNMENT; do
        
        output_debug_info "Role Assignment (JSON): $ROLE_ASSIGNMENT"

        PRINCIPLE_TYPE=$(jq -rc '.principalType // empty' <<< "$ROLE_ASSIGNMENT")
        ROLE_NAME=$(jq -rc '.roleDefinitionName // empty' <<< "$ROLE_ASSIGNMENT")
        
        if [[ $PRINCIPLE_TYPE == "User" ]]; then
            PRINCIPLE_NAME=$(jq -rc '.principalName // empty' <<< "$ROLE_ASSIGNMENT")
            unique_members["$PRINCIPLE_NAME"]=1  # Store unique user in the associative array
        elif [[ $PRINCIPLE_TYPE == "Group" ]]; then
            GROUP_NAME=$(jq -rc '.principalName // empty' <<< "$ROLE_ASSIGNMENT")
            GROUP_MEMBERS=$(get_group_members_serialized "$GROUP_NAME")

            # Split group members and add unique members to the associative array
            IFS=';' read -ra members_array <<< "$GROUP_MEMBERS"
            for member in "${members_array[@]}"; do
                unique_members["$member"]=1
            done
        fi   
    done <<< "$(echo "$ROLE_ASSIGNMENTS" | jq -rc '.[]')"

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
output_debug_info "Subscriptions (JSON): $SUBSCRIPTIONS"

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS != "[]" ]]; then
    output_header

    # Iterate through each subscription
    echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
        parse_subscription

        # Get and process role assignments
        get_role_assignments
        output_debug_info "Role Assignments (JSON): $ROLE_ASSIGNMENTS"
        parse_role_assignments

        output_subscription
    done
else
    output_debug_info "No subscriptions found."
fi


