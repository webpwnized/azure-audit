#!/bin/bash

function parse_redis_list() {
    local redis_json=$1

    REDIS_CACHE_NAME=$(jq -r '.name // empty' <<< "$redis_json")
}

function parse_redis_details() {
    local redis_details=$1

    REDIS_CACHE_LOCATION=$(jq -r '.location // empty' <<< "$redis_details")
    REDIS_CACHE_PUBLIC_NETWORK_ACCESS=$(jq -r '.publicNetworkAccess // empty' <<< "$redis_details")
    REDIS_CACHE_SUBNET_ID=$(jq -r '.subnetId' <<< "$redis_details") #no empty bc could be null
    REDIS_CACHE_PRIVATE_ENDPOINTS=$(jq -r '.privateEndpointConnections[0].id' <<< "$redis_details") #no empty bc could be null

    REDIS_CACHE_IS_VNET_INJECTED="False"
    REDIS_CACHE_HAS_PRIVATE_ENDPOINT="False"
    REDIS_CACHE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"

    # Check if the cache is VNet-injected
    if [[ -n "$REDIS_CACHE_SUBNET_ID" && "$REDIS_CACHE_SUBNET_ID" != "null" ]]; then
        REDIS_CACHE_IS_VNET_INJECTED="True"
    fi
    
    # Check if the cache has any private endpoints
    if [[ -n "$REDIS_CACHE_PRIVATE_ENDPOINTS" && "$REDIS_CACHE_PRIVATE_ENDPOINTS" != "[]" && "$REDIS_CACHE_PRIVATE_ENDPOINTS" != "null" ]]; then
        REDIS_CACHE_HAS_PRIVATE_ENDPOINT="True"
    fi

    # A violation occurs only if public access is enabled AND the cache is NOT VNet-injected <-- this is according to the documentation
    if [[ "$REDIS_CACHE_PUBLIC_NETWORK_ACCESS" == "Enabled" && "$REDIS_CACHE_IS_VNET_INJECTED" == "False" ]]; then
        REDIS_CACHE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    fi
}
