#!/bin/bash

# Debug: ./cis-3.7.1-storage-accounts-public-network-access.sh --subscription 651b4cdc-83bc-466a-975d-df1a9c2be5b1 --resource-group rg-PCD-dev

# Source common constants and functions
source ./common-constants.inc
source ./common-functions.inc

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
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_LOCATION\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$MEMBERS\""
}

# Output resource group information in text format
function output_storage_account_text() {
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
source ./common-menu.inc

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
            
            STORAGE_ACCOUNTS=$(get_storage_accounts "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "Storage Accounts (JSON): $STORAGE_ACCOUNTS"
            
            if [[ $STORAGE_ACCOUNTS != "[]" ]]; then
                echo $STORAGE_ACCOUNTS | jq -rc '.[]' | while IFS='' read STORAGE_ACCOUNT; do
                    output_debug_info "Storage Account (JSON): $STORAGE_ACCOUNT"
                    parse_storage_account "$STORAGE_ACCOUNT"

                    if [[ STORAGE_ACCOUNT_NETWORK_RULESET_DEFAULT_ACTION == "Allow" ]]; then
                        output_user_info "Storage Account $STORAGE_ACCOUNT_NAME in Resource Group $RESOURCE_GROUP_NAME in Subscription $SUBSCRIPTION_NAME is publicly accessible."
                        exit 1
                    fi

                    STORAGE_ACCOUNT_ATTRIBUTES=$(get_storage_account_attributes "$STORAGE_ACCOUNT_NAME" "$STORAGE_ACCOUNT_RESOURCE_GROUP" "$SUBSCRIPTION_NAME")
                    output_debug_info "Storage Account Attributes (JSON): $STORAGE_ACCOUNT_ATTRIBUTES"
                    parse_storage_account_attributes "$STORAGE_ACCOUNT_ATTRIBUTES"

                    STORAGE_ACCOUNT_CONTAINERS=$(get_storage_account_containers "$STORAGE_ACCOUNT_NAME" "$SUBSCRIPTION_NAME") 
                    output_debug_info "Storage Account Containers (JSON): $STORAGE_ACCOUNT_CONTAINERS"
                    parse_storage_account_containers "$STORAGE_ACCOUNT_CONTAINERS"


                    #output_storage_account
                done # End of storage account loop
            fi
        done # End of resource group loop
    else
        # Print message if no resource groups found for subscription
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop
