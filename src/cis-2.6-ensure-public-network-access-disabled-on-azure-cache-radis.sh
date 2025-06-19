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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"REDIS_CACHE_NAME\",\"REDIS_CACHE_LOCATION\",\"REDIS_CACHE_PUBLIC_NETWORK_ACCESS\",\"REDIS_CACHE_SUBNET_ID\",\"REDIS_CACHE_PRIVATE_ENDPOINTS\",\"AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS\",\"REDIS_CACHE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\""
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
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$REDIS_CACHE_NAME\",\"$REDIS_CACHE_LOCATION\",\"$REDIS_CACHE_PUBLIC_NETWORK_ACCESS\",\"$REDIS_CACHE_SUBNET_ID\",\"$REDIS_CACHE_PRIVATE_ENDPOINTS\",\"$AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS\",\"$REDIS_CACHE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\""
}

# Output Key Vault information in text format
function output_redis_list_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Redis Cache Name: $REDIS_CACHE_NAME"
    echo "Redis Cache Location: $REDIS_CACHE_LOCATION"
    echo "Redis Cache Public Network Access: $REDIS_CACHE_PUBLIC_NETWORK_ACCESS"
    echo "Redis Cache Subnet ID: $REDIS_CACHE_SUBNET_ID"
    echo "Redis Cache Private Endpoints: $REDIS_CACHE_PRIVATE_ENDPOINTS"
    echo "Redis Cache Is VNet Injected: $REDIS_CACHE_IS_VNET_INJECTED"
    echo "Redis Cache Has Private Endpoint: $REDIS_CACHE_HAS_PRIVATE_ENDPOINT"
    echo "Azure Cache Redis Public Network Access: $AZURE_CACHE_RADIS_PUBLIC_NETWORK_ACCESS"
    echo "Violation Flag: $REDIS_CACHE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
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
                    parse_redis_list "$REDIS_LIST"

                    REDIS_DETAILS=$(get_azure_redis_details "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$REDIS_CACHE_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Redis Details" "$REDIS_DETAILS"

                    parse_redis_details "$REDIS_DETAILS"

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