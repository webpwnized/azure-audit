#!/bin/bash

# Reference: 10.3.2.3 Ensure default network access rule for storage accounts is set to deny (Automated)  - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0.pdf

# Debug: ./cis-10.3.2.3-ensure-default-network-access-storage-accounts-set-deny.sh --subscription 651b4cdc-83bc-466a-975d-df1a9c2be5b1 --resource-group rg-PCD-dev

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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"RESOURCE_GROUP_NAME\",\"STORAGE_ACCOUNT_NAME\",\"STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS_RULE\",\"STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS_RULE_VIOLATION_FLAG\""
}

# Output resource group information
function output_storage_account() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_storage_account_helper
    fi
}

# Determine output format and call appropriate function for resource group
function output_storage_account_helper() {
    # Check if CSV output is enabled
    if [[ $CSV == "True" ]]; then
        output_storage_account_csv
    else
        output_storage_account_text
    fi
}

# Output resource group information in CSV format
function output_storage_account_csv() {
    # Output resource group details in CSV format
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$RESOURCE_GROUP_NAME\",\"$STORAGE_ACCOUNT_NAME\",\"$STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS_RULE\",\"$STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS_RULE_VIOLATION_FLAG\""
}

# Output resource group information in text format
function output_storage_account_text() {
    # Output resource group details in text format
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
    echo "Storage Account Private Endpoint Access: $STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS_RULE"
    echo "Storage Account Private Endpoint Access Violation Flag: $STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS_RULE_VIOLATION_FLAG"
    echo $BLANK_LINE
}

# Source common menu
source ./includes/common-menu.inc

# Get subscriptions
SUBSCRIPTIONS="$(get_subscriptions "$p_SUBSCRIPTION_ID")"
output_debug_info "" "" "Subscriptions" $SUBSCRIPTIONS;

check_if_subscriptions_exists "$SUBSCRIPTIONS"

# Output header if CSV format is enabled
output_header

# Process each subscription
echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
    output_debug_info "" "" "Subscription" "$SUBSCRIPTION"
    
    # Parse subscription information
    parse_subscription "$SUBSCRIPTION"
    
    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME)

    output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Groups" "$RESOURCE_GROUPS"

    # Process each resource group
    if [[ $RESOURCE_GROUPS != "[]" ]]; then
        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do

            output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Group" "$RESOURCE_GROUP"

            # Parse resource group information
            parse_resource_group "$RESOURCE_GROUP"
            
            STORAGE_ACCOUNTS=$(get_storage_accounts "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Storage Accounts" "$STORAGE_ACCOUNTS"
            
            if [[ $STORAGE_ACCOUNTS != "[]" ]]; then
                echo $STORAGE_ACCOUNTS | jq -rc '.[]' | while IFS='' read STORAGE_ACCOUNT; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Storage Account" "$STORAGE_ACCOUNT"
                    parse_storage_account "$STORAGE_ACCOUNT"

                    STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS=$(get_storage_account_network_default "$STORAGE_ACCOUNT_NAME" "$RESOURCE_GROUP_NAME" "$SUBSCRIPTION_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Storage Account Deafult Network Access" "$STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS"

                    parse_storage_account_default_network_acess "$STORAGE_ACCOUNT_DEFAULT_NETWORK_ACCESS"

                    output_storage_account
                done # End of storage account loop
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop
