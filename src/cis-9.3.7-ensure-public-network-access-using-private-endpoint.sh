#!/bin/bash

# Reference: 9.3.7 Ensure that Public Network Access when using Private Endpoint is disabled (Automated) - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0

# Debug: ./cis-9.3.7-ensure-public-network-access-using-private-endpoint.sh -s tbd -r tbd

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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"KEY_VAULT_NAME\",\"KEY_VAULT_LOCATION\",\"PUBLIC_NETWORK_ACCESS\",\"VIOLATION_FLAG\""
}

function output_key_vault() {
    if [[ $CSV == "True" ]]; then
        output_key_vault_csv
    else
        output_key_vault_text
    fi
}

# Output Key Vault information in CSV format
function output_key_vault_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$KEY_VAULT_NAME\",\"$KEY_VAULT_LOCATION\",\"$KEY_VAULT_PUBLIC_NETWORK_ACCESS\",\"$KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\""
}

# Output Key Vault information in text format
function output_key_vault_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Key Vault Name: $KEY_VAULT_NAME"
    echo "Key Vault Location: $KEY_VAULT_LOCATION"
    echo "Public Network Access: $KEY_VAULT_PUBLIC_NETWORK_ACCESS"
    echo "Violation Flag: $KEY_VAULT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo $BLANK_LINE
}

# Include common menu
source ./includes/common-menu.inc

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
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

            KEY_VAULTS=$(get_key_vaults "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Key vaults" "$KEY_VAULTS"
            
            if [[ "$KEY_VAULTS" != "[]" ]]; then
                echo "$KEY_VAULTS" | jq -rc '.[]' | while IFS='' read -r KEY_VAULT; do
                    parse_key_vault "$KEY_VAULT"
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Key Vault" "$KEY_VAULT_NAME"

                    KEY_VAULT_PUBLIC_NETWORK_ACCESS=$(get_specific_key_vault_information "$KEY_VAULT_NAME" "$RESOURCE_GROUP_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Key vaults" "$KEY_VAULT_PUBLIC_NETWORK_ACCESS"
                    
                    parse_key_vault_public_network_access "$KEY_VAULT_PUBLIC_NETWORK_ACCESS"

                    output_key_vault

                done # End of Key Vault loop
            else
                output_user_info "No Key Vaults found in resource group $RESOURCE_GROUP_NAME"
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop

output_user_info "Audit complete."