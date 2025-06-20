#!/bin/bash

function parse_cosmosdb_name(){
    local cosmosdb_json=$1

    COSMOSDB_NAME=$(jq -rc '.name // empty' <<< "$cosmosdb_json")
}

function parse_cosmosdb_full() {
    local cosmosdb_details_json=$1

    COSMOSDB_LOCATION=$(jq -rc '.location // empty' <<< "$cosmosdb_details_json")
    VIRTUAL_NETWORK_FILTER_ENABLED=$(jq -rc '.isVirtualNetworkFilterEnabled // empty' <<< "$cosmosdb_details_json")

    VIRTUAL_NETWORK_FILTER_ENABLED_VIOLATION_FLAG="False"

    if [[ "$VIRTUAL_NETWORK_FILTER_ENABLED" != "true" ]]; then
        VIRTUAL_NETWORK_FILTER_ENABLED_VIOLATION_FLAG="True"
    fi
}
