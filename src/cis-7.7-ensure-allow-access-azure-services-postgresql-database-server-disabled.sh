#!/bin/bash

# Reference: Ensure 'Allow access to Azure services' for PostgreSQL Database Server is disabled (Automated) - CIS_Microsoft_Azure_Database_Services_Benchmark_v1.0.0

# Debug: ./cis-7.7-ensure-allow-access-azure-services-postgresql-database-server-disabled.sh -s SUBSCRIPTION_ID -r RESOURCE_NAME --debug

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
    echo "SUBSCRIPTION_NAME,SUBSCRIPTION_ID,RESOURCE_GROUP_NAME,POSTGRES_SERVER_NAME,POSTGRES_SERVER_LOCATION,POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS,POSTGRES_SERVER_START_IP_ADDRESS,POSTGRES_SERVER_END_IP_ADDRESS,POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG,POSTGRES_SERVER_START_IP_ADDRESS_VIOLATION_FLAG,POSTGRES_SERVER_END_IP_ADDRESS_VIOLATION_FLAG"
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

# Output Postgresql information in CSV format
function output_postgresql_csv() {
    echo "$SUBSCRIPTION_NAME,$SUBSCRIPTION_ID,$RESOURCE_GROUP_NAME,$POSTGRES_SERVER_NAME,$POSTGRES_SERVER_LOCATION,$POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS,$POSTGRES_SERVER_START_IP_ADDRESS,$POSTGRES_SERVER_END_IP_ADDRESS,$POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG,$POSTGRES_SERVER_START_IP_ADDRESS_VIOLATION_FLAG,$POSTGRES_SERVER_END_IP_ADDRESS_VIOLATION_FLAG"
}

# Output Postgresql Vault information in text format
function output_postgresql_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "PostgreSQL Server Name: $POSTGRES_SERVER_NAME"
    echo "PostgreSQL Server Location: $POSTGRES_SERVER_LOCATION"
    echo "Allow Azure Services Access: $POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS"
    echo "Start IP Address: $POSTGRES_SERVER_START_IP_ADDRESS"
    echo "End IP Address: $POSTGRES_SERVER_END_IP_ADDRESS"
    echo "Violation Flag: $POSTGRES_SERVER_ALLOW_AZURE_SERVICES_ACCESS_VIOLATION_FLAG"
    echo "Start IP Address Violation Flag: $POSTGRES_SERVER_START_IP_ADDRESS_VIOLATION_FLAG"
    echo "End IP Address Violation Flag: $POSTGRES_SERVER_END_IP_ADDRESS_VIOLATION_FLAG"
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

                    POSTGRES_SERVER_FIREWALL_RULES=$(get_postgres_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$POSTGRES_SERVER_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Server Firewall Rules" "$POSTGRES_SERVER_FIREWALL_RULES"

                    if [[ $POSTGRES_SERVER_FIREWALL_RULES != "[]" ]]; then
                        echo $POSTGRES_SERVER_FIREWALL_RULES | jq -rc '.[]' | while IFS='' read POSTGRES_SERVER_FIREWALL_RULE; do
                            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Server Firewall Rule" "$POSTGRES_SERVER_FIREWALL_RULE"
                            parse_firewall_rules "$POSTGRES_SERVER_FIREWALL_RULE"

                            output_postgresql_helper
                        done
                    else
                        output_user_info "No firewall rules found for Postgres Server $POSTGRES_SERVER_NAME in resource group $RESOURCE_GROUP_NAME"
                    fi
                done # End of PostGres Server loop
            else
                output_user_info "No Postgres Servers found in resource group $RESOURCE_GROUP_NAME"
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop