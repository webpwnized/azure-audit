#!/bin/bash

function parse_key_vault() {
    local l_key_vault_json=$1

    # Extract properties
    KEY_VAULT_NAME=$(jq -r '.name // empty' <<< "$l_key_vault_json");
    KEY_VAULT_LOCATION=$(jq -r '.location // empty' <<< "$l_key_vault_json");

    # TDL: move this to a fetch function in the fetch-functions.inc
    local vault_details=$(az keyvault show --name "$KEY_VAULT_NAME" --resource-group "$RESOURCE_GROUP_NAME") #might need a subscription parameter: --subscription "$SUBSCRIPTION_ID
    
    KEY_VAULT_PUBLIC_NETWORK_ACCESS=$(echo "$vault_details" | jq -r '.properties.publicNetworkAccess')

    KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"

    # Check for violation
    if [[ "$KEY_VAULT_PUBLIC_NETWORK_ACCESS" != "Disabled" ]]; then
        KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    fi
}

