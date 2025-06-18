#!/bin/bash

function parse_redis_list() {
    local redis_json=$1

    # Use 'az redis show' to get the full resource properties
    REDIS_CACHE_NAME=$(echo "$redis_json" | jq -r '.name')
    local redis_details
    redis_details=$(az redis show --name "$REDIS_CACHE_NAME" --resource-group "$RESOURCE_GROUP_NAME" --subscription "$SUBSCRIPTION_ID")

    # Extract properties
    REDIS_CACHE_LOCATION=$(echo "$redis_details" | jq -r '.location')
    PUBLIC_NETWORK_ACCESS=$(echo "$redis_details" | jq -r '.publicNetworkAccess')
    local subnet_id
    subnet_id=$(echo "$redis_details" | jq -r '.subnetId')
    local private_endpoints
    private_endpoints=$(echo "$redis_details" | jq -r '.privateEndpointConnections')


    # Default values
    IS_VNET_INJECTED="False"
    HAS_PRIVATE_ENDPOINT="False"
    VIOLATION_FLAG="False"
    REMEDIATION_STATUS="N/A"

    # Check if the cache is VNet-injected
    if [[ -n "$subnet_id" && "$subnet_id" != "null" ]]; then
        IS_VNET_INJECTED="True"
    fi
    
    # Check if the cache has any private endpoints
    if [[ -n "$private_endpoints" && "$private_endpoints" != "[]" && "$private_endpoints" != "null" ]]; then
        HAS_PRIVATE_ENDPOINT="True"
    fi

    # Check for violation
    # A violation occurs only if public access is enabled AND the cache is NOT VNet-injected.
    if [[ "$PUBLIC_NETWORK_ACCESS" == "Enabled" && "$IS_VNET_INJECTED" == "False" ]]; then
        VIOLATION_FLAG="True"
    fi

    # If VNet injected, the control is not applicable
    if [[ "$IS_VNET_INJECTED" == "True" ]]; then
        REMEDIATION_STATUS="Not Applicable (VNet Injected)"
    fi
}
