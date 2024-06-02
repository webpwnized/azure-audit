#!/bin/bash

# Debug: ./utility-list-resource-groups.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

# Source common constants and functions
source ./includes/common-constants.inc
source ./includes/common-functions.inc

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

# Source common menu
source ./includes/common-menu.inc

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
output_debug_info "Subscriptions (JSON): $SUBSCRIPTIONS";

check_if_subscriptions_exists "$SUBSCRIPTIONS"

# Output header if CSV format is enabled
output_header

# Process each subscription
echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
    output_debug_info "Subscription (JSON): $SUBSCRIPTION"
    
    # Parse subscription information
    parse_subscription "$SUBSCRIPTION"
    
    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME)

    output_debug_info "Resource Groups (JSON): $RESOURCE_GROUPS"

    # Process each resource group
    if [[ $RESOURCE_GROUPS != "[]" ]]; then
        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do

            output_debug_info "Resource Group (JSON): $RESOURCE_GROUP"

            # Parse resource group information
            parse_resource_group "$RESOURCE_GROUP"
            
            # Get and process role assignments
            ROLE_ASSIGNMENTS=$(get_resource_group_role_assignments "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "Role Assignments (JSON): $ROLE_ASSIGNMENTS"
            parse_role_assignments "$ROLE_ASSIGNMENTS"

            # Output resource group details
            output_resource_group
        done
    else
        # Print message if no resource groups found for subscription
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done
