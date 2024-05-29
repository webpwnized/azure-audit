#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql

# Debug: ./cis-4.1.2-azure-sql-databases-allowing-ingress.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

# Include common constants and functions
source ./common-constants.inc
source ./common-functions.inc

# Function to output header based on CSV flag
function output_header() {
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Function to output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"SQL_SERVER_NAME\",\"SQL_SERVER_DOMAIN_NAME\",\"SQL_SERVER_TYPE\",\"SQL_SERVER_ENVIRONMENT\",\"SQL_SERVER_APPLICATION_CODE\",\"SQL_SERVER_APPLICATION_NAME\",\"SQL_SERVER_REQUESTOR_AD_ID\",\"SQL_SERVER_REQUESTOR_EMPLOYEE_ID\",\"SQL_SERVER_PUBLIC_NETWORK_ACCESS\",\"SQL_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"SQL_SERVER_ADMIN_LOGIN\",\"SQL_SERVER_ADMIN_TYPE\",\"SQL_SERVER_ADMIN_PRINCIPLE_TYPE\",\"SQL_SERVER_ADMIN_PRINCIPLE_LOGIN\",\"SQL_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"SQL_SERVER_TLS_VERSION\",\"SQL_SERVER_LOCATION\",\"SQL_SERVER_VERSION\",\"SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"FIREWALL_RULE_NAME\",\"FIREWALL_RULE_START_IP_ADDRESS\",\"FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"FIREWALL_RULE_WHOIS_OUTPUT\",\"SQL_SERVER_SQLCMD_CONNECT\""
}

# Function to output SQL server firewall rule in CSV format
function output_sql_server_firewall_rule_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$SQL_SERVER_NAME\",\"$SQL_SERVER_DOMAIN_NAME\",\"$SQL_SERVER_TYPE\",\"$SQL_SERVER_ENVIRONMENT\",\"$SQL_SERVER_APPLICATION_CODE\",\"$SQL_SERVER_APPLICATION_NAME\",\"$SQL_SERVER_REQUESTOR_AD_ID\",\"$SQL_SERVER_REQUESTOR_EMPLOYEE_ID\",\"$SQL_SERVER_PUBLIC_NETWORK_ACCESS\",\"$SQL_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"$SQL_SERVER_ADMIN_LOGIN\",\"$SQL_SERVER_ADMIN_TYPE\",\"$SQL_SERVER_ADMIN_PRINCIPLE_TYPE\",\"$SQL_SERVER_ADMIN_PRINCIPLE_LOGIN\",\"$SQL_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"$SQL_SERVER_TLS_VERSION\",\"$SQL_SERVER_LOCATION\",\"$SQL_SERVER_VERSION\",\"$SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"$FIREWALL_RULE_NAME\",\"$FIREWALL_RULE_START_IP_ADDRESS\",\"$FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"$FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"$FIREWALL_RULE_WHOIS_OUTPUT\",\"$SQL_SERVER_SQLCMD_CONNECT\""
}

# Function to output SQL server firewall rule
function output_sql_server_firewall_rule() {
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_sql_server_firewall_rule_helper
    fi
}

# Helper function to output SQL server firewall rule
function output_sql_server_firewall_rule_helper() {
    if [[ $CSV == "True" ]]; then
        output_sql_server_firewall_rule_csv
    else
        output_sql_server_firewall_rule_text
    fi
}

# Function to output SQL server firewall rule in text format
function output_sql_server_firewall_rule_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE"
    echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE"
    echo "Resource Group PAR: $RESOURCE_GROUP_PAR"
    echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID"
    echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID"
    echo "SQL Server Name: $SQL_SERVER_NAME"
    echo "SQL Server Environment: $SQL_SERVER_ENVIRONMENT"
    echo "SQL Server Application Code: $SQL_SERVER_APPLICATION_CODE"
    echo "SQL Server Application Name: $SQL_SERVER_APPLICATION_NAME"
    echo "SQL Server Requestor AD ID: $SQL_SERVER_REQUESTOR_AD_ID"
    echo "SQL Server Employee ID: $SQL_SERVER_REQUESTOR_EMPLOYEE_ID"
    echo "SQL Server Domain Name: $SQL_SERVER_DOMAIN_NAME"
    echo "SQL Server Type: $SQL_SERVER_TYPE"
    echo "SQL Server Allows Public Network Access: $SQL_SERVER_PUBLIC_NETWORK_ACCESS"
    echo "SQL Server Allow Outbound Access: $SQL_SERVER_RESTRICT_OUTBOUND_ACCESS"
    echo "SQL Server Login: $SQL_SERVER_ADMIN_LOGIN"
    echo "SQL Server Admin Type: $SQL_SERVER_ADMIN_TYPE"
    echo "SQL Server Admin Principle Type: $SQL_SERVER_ADMIN_PRINCIPLE_TYPE"
    echo "SQL Server Admin Principle Login: $SQL_SERVER_ADMIN_PRINCIPLE_LOGIN"
    echo "SQL Server Admin Requires Azure Login: $SQL_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG"
    echo "SQL Server TLS Version: $SQL_SERVER_TLS_VERSION"
    echo "SQL Server Location: $SQL_SERVER_LOCATION"
    echo "SQL Server Version: $SQL_SERVER_VERSION"
    echo "Firewall Rule Name: $FIREWALL_RULE_NAME"
    echo "Firewall Rule Start IP Address: $FIREWALL_RULE_START_IP_ADDRESS"
    echo "Firewall Rule End IP Address: $FIREWALL_RULE_END_IP_ADDRESS"
    echo "Firewall Rule Resource Group: $FIREWALL_RULE_RESOURCE_GROUP"
    echo "Whois Information: $FIREWALL_RULE_WHOIS_OUTPUT"
    echo "SQL Server SQLCMD Connect: $SQL_SERVER_SQLCMD_CONNECT"
    echo $BLANK_LINE
}

# Include common menu
source ./common-menu.inc

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
output_debug_info "Subscriptions (JSON): $SUBSCRIPTIONS";

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS == "[]" ]]; then
    output_user_info "No subscriptions found.";
    exit 0
fi

output_header

echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do

    output_debug_info "Subscription (JSON): $SUBSCRIPTION"
    
    # Parse subscription information
    parse_subscription "$SUBSCRIPTION"
    
    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME")
    output_debug_info "Resources Groups (JSON): $RESOURCE_GROUPS"

    # Process each resource group
    if [[ $RESOURCE_GROUPS != "[]" ]]; then

        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do

            output_debug_info "Resource Group (JSON): $RESOURCE_GROUP"   

            # Parse resource group information
            parse_resource_group "$RESOURCE_GROUP"
            
            # Get SQL servers for the resource group
            declare SQL_SERVERS=$(get_azure_sql_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "SQL Servers (JSON): $SQL_SERVERS"

            # Process each SQL server
            if [[ $SQL_SERVERS != "[]" ]]; then
                echo $SQL_SERVERS | jq -rc '.[]' | while IFS='' read SQL_SERVER; do
                    output_debug_info "SQL Server (JSON): $SQL_SERVER"

                    # Parse SQL server information
                    parse_azure_sql_server "$SQL_SERVER"
                    
                    # Get firewall rules for the SQL server
                    declare SQL_SERVER_FIREWALL_RULES=$(get_azure_sql_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$SQL_SERVER_NAME")
                    output_debug_info "SQL Server Firewall Rules (JSON): $SQL_SERVER_FIREWALL_RULES"

                    if [[ $SQL_SERVER_FIREWALL_RULES != "[]" ]]; then
                        echo $SQL_SERVER_FIREWALL_RULES | jq -rc '.[]' | while IFS='' read FIREWALL_RULE; do
                            output_debug_info "SQL Server Firewall Rule (JSON): $FIREWALL_RULE"
                            
                            # Parse firewall rule information
                            parse_azure_sql_server_firewall_rule "$FIREWALL_RULE"

                            # Output SQL server firewall rule if it does not violate conditions
                            #if [[ ! $FIREWALL_RULE_NAME =~ ^ClientIPAddress ]]; then
                                output_sql_server_firewall_rule
                            #fi # End of firewall rule check
                        done # End of firewall rule processing
                    else
                        # Print message if no firewall rules found
                        output_user_info "No SQL server firewall rules found"
                    fi # End of firewall rule processing
                done # End of SQL server processing
            else
                # Print message if no SQL servers found
                output_user_info "No SQL servers found"
            fi # End of SQL server processing
        done # End of resource group processing
    else
        # Print message if no resource groups found
        output_user_info "No resource groups found"
    fi # End of resource group processing
done # End of subscription processing
