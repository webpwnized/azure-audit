#!/bin/bash

# Reference: 2.6 Ensure that 'Public Network Access' is 'Disabled' (Manual) - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0

# Debug: ./cis-2.6-ensure-public-network-access-disabled-on-azure-cache-radis.sh -s tbd -r tbd

# Include common constants and functions
source ./includes/common-constants.inc;
source ./includes/common-functions.inc;

# Function to output header based on CSV flag
function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header
	fi
}

# Output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"REDIS_INSTANCE\",\"AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS\",\"AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\""
}

# Output resource group information
function output_redis_list_helper() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_redis_list
    fi
}

function output_redis_list() {
    if [[ $CSV == "True" ]]; then
        output_redis_list_text
    else
        output_redis_list_csv
    fi
}

# Output Key Vault information in CSV format
function output_redis_list_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$REDIS_INSTANCE\",\"$AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS\",\"$AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\""
}

# Output Key Vault information in text format
function output_redis_list_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Redis Instance: $REDIS_INSTANCE"
    echo "Azure Cache Redis Public Network Access: $AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS"
    echo "Violation Flag: $AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo $BLANK_LINE
}

# Include common menu
source ./includes/common-menu.inc

# Get subscriptions
SUBSCRIPTIONS="$(get_subscriptions "$p_SUBSCRIPTION_ID")"
output_debug_info "" "" "Subscriptions" "$SUBSCRIPTIONS";

check_if_subscriptions_exists "$SUBSCRIPTIONS"

output_header

# Process each subscription
echo "$SUBSCRIPTIONS" | jq -rc '.[]' | while IFS='' read -r SUBSCRIPTION; do
    output_debug_info "" "" "Subscription" "$SUBSCRIPTION"

    parse_subscription "$SUBSCRIPTION"

    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Groups" "$RESOURCE_GROUPS"

    if [[ $RESOURCE_GROUPS != "[]" ]]; then
        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do
            output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Group" "$RESOURCE_GROUP"
            parse_resource_group "$RESOURCE_GROUP"

            REDIS_LISTS=$(get_azure_redis_list "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Redis Lists" "$REDIS_LISTS"
            
            if [[ "$REDIS_LISTS" != "[]" ]]; then
                echo "$REDIS_LISTS" | jq -rc '.[]' | while IFS='' read -r REDIS_LIST; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Redis List" "$REDIS_LIST"
                    # parse_key_vault "$KEY_VAULT"

                    # KEY_VAULT_PUBLIC_NETWORK_ACCESS=$(get_specific_key_vault_information "$KEY_VAULT_NAME" "$RESOURCE_GROUP_NAME")
                    # output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Key vault public network access" "$KEY_VAULT_PUBLIC_NETWORK_ACCESS"

                    # parse_key_vault_public_network_access "$KEY_VAULT_PUBLIC_NETWORK_ACCESS"

                    output_redis_list_helper

                done # End of Key Vault loop
            else
                output_user_info "No Redis Lists found in resource group $RESOURCE_GROUP_NAME"
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop

function get_azure_redis_list() {
    local subscription_name=$1
    local resource_group_name=$2

    az redis list \
        --subscription "$subscription_name" \
        --resource-group "$resource_group_name" \
        --output="json" 2>/dev/null
}