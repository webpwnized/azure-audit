#!/bin/bash

# Debug: ./utility-list-resource-groups.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

# Source common constants and functions
source ./common-constants.inc
source ./functions.inc

# Output header based on CSV flag
function output_header() {
    # Check if CSV output is enabled
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Output CSV header
function output_csv_header() {
    # Output CSV header line
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_LOCATION\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"MEMBERS\""
}

# Output resource group information
function output_resource_group() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_resource_group_helper
    fi
}

# Determine output format and call appropriate function for resource group
function output_resource_group_helper() {
    # Check if CSV output is enabled
    if [[ $CSV == "True" ]]; then
        output_resource_group_csv
    else
        output_resource_group_text
    fi
}

# Output resource group information in CSV format
function output_resource_group_csv() {
    # Output resource group details in CSV format
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_LOCATION\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$MEMBERS\""
}

# Output resource group information in text format
function output_resource_group_text() {
    # Output resource group details in text format
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Resource Group Location: $RESOURCE_GROUP_LOCATION"
    echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE"
    echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE"
    echo "Resource Group PAR: $RESOURCE_GROUP_PAR"
    echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID"
    echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID"
    echo "Members: $MEMBERS"
    echo $BLANK_LINE
}

# Parse resource group information
function parse_resource_group() {
    # Parse resource group information from JSON
    RESOURCE_GROUP_NAME=$(jq -rc '.name // empty' <<< "$RESOURCE_GROUP")
    RESOURCE_GROUP_LOCATION=$(jq -rc '.location // empty' <<< "$RESOURCE_GROUP")
    RESOURCE_GROUP_APPLICATION_CODE=$(jq -rc '.tags.applicationCode // empty' <<< "$RESOURCE_GROUP")
    RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(jq -rc '.tags.departmentChargeCode // empty' <<< "$RESOURCE_GROUP")
    RESOURCE_GROUP_PAR=$(jq -rc '.tags.par // empty' <<< "$RESOURCE_GROUP")
    RESOURCE_GROUP_REQUESTOR_AD_ID=$(jq -rc '.tags.requestorAdId // empty' <<< "$RESOURCE_GROUP")
    RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(jq -rc '.tags.requestorEmployeeId // empty' <<< "$RESOURCE_GROUP")
}

function parse_subscription() {
    # Parse subscription information from JSON
    SUBSCRIPTION_NAME=$(jq -rc '.displayName // empty' <<< "$SUBSCRIPTION")
    SUBSCRIPTION_STATE=$(jq -rc '.state // empty' <<< "$SUBSCRIPTION")
    SUBSCRIPTION_ID=$(jq -rc '.subscriptionId // empty' <<< "$SUBSCRIPTION")
}

function get_role_assignments() {
    # Get role assignments and store in a variable
    ROLE_ASSIGNMENTS=$(get_resource_group_role_assignments "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
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
    # Output header if CSV format is enabled
    output_header
    
    # Process each subscription
    echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
        # Parse subscription information
        parse_subscription
        
        # Get resource groups for the subscription
        declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME)

        output_debug_info "Resources Groups (JSON): $RESOURCE_GROUPS"

        # Process each resource group
        if [[ $RESOURCE_GROUPS != "[]" ]]; then
            echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do

                output_debug_info "Resources Group (JSON): $RESOURCE_GROUP"

                # Parse resource group information
                parse_resource_group
                
                # Get and process role assignments
                get_role_assignments
                output_debug_info "Role Assignments (JSON): $ROLE_ASSIGNMENTS"
                parse_role_assignments

                # Output resource group details
                output_resource_group
            done
        else
            # Print message if no resource groups found for subscription
            output_debug_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
        fi
    done
else
    # Print message if no subscriptions found
    output_debug_info "No subscriptions found"
fi
