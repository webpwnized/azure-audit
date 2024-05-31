#!/bin/bash

function parse_storage_account() {
    STORAGE_ACCOUNT="$1"

    STORAGE_ACCOUNT_NAME=$(jq -r '.name' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_LOCATION=$(jq -r '.location' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_RESOURCE_GROUP=$(jq -r '.resourceGroup' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_NETWORK_RULESET_DEFAULT_ACTION=$(jq -r '.networkRuleSet.defaultAction' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_BLOB=$(jq -r '.primaryEndpoints.blob' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_DFS=$(jq -r '.primaryEndpoints.dfs' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_FILE=$(jq -r '.primaryEndpoints.file' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_QUEUE=$(jq -r '.primaryEndpoints.queue' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_TABLE=$(jq -r '.primaryEndpoints.table' <<< "$STORAGE_ACCOUNT")
    STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_WEB=$(jq -r '.primaryEndpoints.web' <<< "$STORAGE_ACCOUNT")
}

function parse_storage_account_attributes() {
    STORAGE_ACCOUNT="$1"
}

function parse_storage_account_containers() {
    STORAGE_ACCOUNT="$1"
}