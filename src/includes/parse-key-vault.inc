#!/bin/bash

function parse_key_vault_public_network_access() {
    local l_key_vault_json=$1

    KEY_VAULT_PUBLIC_NETWORK_ACCESS=$(jq -r '.properties.publicNetworkAccess // empty' <<< "$l_key_vault_json")
    KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"

    # Check for violation
    if [[ "$KEY_VAULT_PUBLIC_NETWORK_ACCESS" != "Disabled" ]]; then
        KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    fi
}
