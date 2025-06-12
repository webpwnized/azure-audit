#!/bin/bash

#reference: 10.1 Ensure that 'Auditing' is set to on (Automated) - for Azure SQL Servers - CIS_Microsoft_Azure_Database_Services_Benchmark_v1.0.0.pdf

# Debug: ./cis-10.1-ensure-auditing-set-on-for-azure-sql-servers.sh --subscription tbd --resource-group tbd

# Source common constants and functions
source ./includes/common-constants.inc
source ./includes/common-functions.inc

# Output header based on CSV flag
function output_header() {
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"SQL_SERVER_NAME\",\"SQL_SERVER_LOCATION\",\"SQL_SERVER_AUDITING_ENABLED\",\"SQL_SERVER_AUDITING_ENABLED_FLAG\""
}

# Output resource group information
function output_sql_server_account() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_sql_server_audit_helper
    fi
}

# Determine output format and call appropriate function for resource group
function output_sql_server_audit_helper() {
    if [[ $CSV == "True" ]]; then
        output_sql_server_audit_csv
    else
        output_sql_server_audit_text
    fi
}

# Output resource group information in CSV format
function output_sql_server_audit_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$SQL_SERVER_NAME\",\"$SQL_SERVER_LOCATION\",\"$SQL_SERVER_AUDITING_ENABLED\",\"$SQL_SERVER_AUDITING_ENABLED_FLAG\""
}

# Output resource group information in text format
function output_sql_server_audit_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "SQL Server Name: $SQL_SERVER_NAME"
    echo "SQL Server Location: $SQL_SERVER_LOCATION"
    echo "Auditing Enabled: $SQL_SERVER_AUDITING_ENABLED"
    echo "Violation Flag: $SQL_SERVER_AUDITING_ENABLED_FLAG"
    echo $BLANK_LINE
}

# Source common menu
source ./includes/common-menu.inc

# Get subscriptions
# declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
SUBSCRIPTIONS="$(get_subscriptions "$p_SUBSCRIPTION_ID")"
output_debug_info "" "" "Subscriptions" $SUBSCRIPTIONS;

check_if_subscriptions_exists "$SUBSCRIPTIONS"

# Output header if CSV format is enabled
output_header

# Process each subscription
echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
    parse_subscription "$SUBSCRIPTION"
    output_debug_info "$SUBSCRIPTION_NAME" "" "Subscription" "$SUBSCRIPTION"
    
    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME)
    output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Groups" "$RESOURCE_GROUPS"

    # Process each resource group
    if [[ $RESOURCE_GROUPS != "[]" ]]; then
        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do
            output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Group" "$RESOURCE_GROUP"
            parse_resource_group "$RESOURCE_GROUP"
            
            # Get SQL Servers for the resource group
            declare SQL_SERVERS=$(get_azure_sql_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Servers" "$SQL_SERVERS"

            if [[ $SQL_SERVERS != "[]" ]]; then
                echo $SQL_SERVERS | jq -rc '.[]' | while IFS='' read SQL_SERVER; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Server" "$SQL_SERVER"
                    parse_azure_sql_server "$SQL_SERVER"
                    
                    declare SQL_SERVER_AUDIT_POLICY=$(get_sql_server_audit_policy "$SQL_SERVER_NAME" "$RESOURCE_GROUP_NAME" "$SUBSCRIPTION_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Servers" "$SQL_SERVER_AUDIT_POLICY"

                    parse_sql_server_audit_policy "$SQL_SERVER_AUDIT_POLICY"
                    output_sql_server_account

                done # End of SQL server processing
            else
                output_user_info "No SQL servers found"
            fi # End of SQL server processing
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop
