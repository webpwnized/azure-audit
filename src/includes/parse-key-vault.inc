#!/bin/bash

function parse_key_vault() {
    local l_key_vault_json=$1

    # Extract properties
    KEY_VAULT_NAME=$(jq -r '.name // empty' <<< "$l_key_vault_json");
    KEY_VAULT_LOCATION=$(jq -r '.location // empty' <<< "$l_key_vault_json");
}

function parse_key_vault_public_network_access() {
    local l_key_vault_json=$1

    # Extract public network access
    KEY_VAULT_PUBLIC_NETWORK_ACCESS=$(jq -r '.properties.publicNetworkAccess // empty' <<< "$l_key_vault_json")
    KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"

    # Check for violation
    if [[ "$KEY_VAULT_PUBLIC_NETWORK_ACCESS" != "Disabled" ]]; then
        KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    fi
}
