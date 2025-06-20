#!/bin/bash

# Reference: Ensure 'Allow access to Azure services' for PostgreSQL Database Server is disabled (Automated) - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0

# Debug: ./cis-7.7-ensure-allow-access-azure-services-postgresql-database-server-disabled.sh -s tbd -r tbd

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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"POSTGRES_SERVER_NAME\",\"POSTGRES_SERVER_LOCATION\",\"POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS\",\"POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG\""
}

# Output resource group information
function output_postgresql_helper() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_postgresql
    fi
}

function output_postgresql() {
    if [[ $CSV == "True" ]]; then
        output_postgresql_csv
    else
        output_postgresql_text
    fi
}

# Output Key Vault information in CSV format
function output_postgresql_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$POSTGRES_SERVER_NAME\",\"$POSTGRES_SERVER_LOCATION\",\"$POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS\",\"$POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG\""
}

# Output Key Vault information in text format
function output_postgresql_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "PostgreSQL Server Name: $POSTGRES_SERVER_NAME"
    echo "PostgreSQL Server Location: $POSTGRES_SERVER_LOCATION"
    echo "Allow Azure Services Access: $POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS"
    echo "Violation Flag: $POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG"
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

            POSTGRES_SERVERS=$(get_postgres_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Servers" "$POSTGRES_SERVERS"
            
            if [[ "$POSTGRES_SERVERS" != "[]" ]]; then
                echo "$POSTGRES_SERVERS" | jq -rc '.[]' | while IFS='' read -r POSTGRES_SERVER; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Server" "$POSTGRES_SERVER"
                    parse_postgres_server "$POSTGRES_SERVER"

                    POSTGRES_SERVER_FIREWALL_RULES=$(get_postgres_server_firewall_rules "$KEY_VAULT_NAME" "$RESOURCE_GROUP_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Server Firewall Rules" "$POSTGRES_SERVER_FIREWALL_RULES"

                    # parse_key_vault_public_network_access "$KEY_VAULT_PUBLIC_NETWORK_ACCESS"

                    output_postgresql_helper

                done # End of Key Vault loop
            else
                output_user_info "No Postgres Servers found in resource group $RESOURCE_GROUP_NAME"
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop

function parse_postgres_server() {
    local postgres_server_json=$1

    # Extract properties
    POSTGRES_SERVER_NAME=$(jq -rc '.name // empty' <<< "$postgres_server_json")
    POSTGRES_SERVER_LOCATION=$(jq -rc '.location // empty' <<< "$postgres_server_json")
}

function parse_firewall_rules() {
    local firewall_rules_json=$1

    POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG="False"

    POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS=$(jq -rc '.[] | select(.name == "AllowAllWindowsAzureIps")' <<< "$postgres_server_json")
    
    if [[ -n "$POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS" ]]; then
        POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG="True"
    fi
}