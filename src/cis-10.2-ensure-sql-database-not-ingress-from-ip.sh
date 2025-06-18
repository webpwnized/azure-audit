#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql
# Reference: 10.2 Ensure no Azure SQL Databases allow ingress from 0.0.0.0/0 (ANY IP) (Automated) - CIS_Microsoft_Azure_Database_Services_Benchmark_v1.0.0.pdf

# Debug: ./cis-10.2-ensure-sql-database-not-ingress-from-ip.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

# Output Fields Documentation

# SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG
# Values: "True" or "False"
# Description: Indicates if public network access to the SQL server is enabled. It is set to "True" if the publicNetworkAccess property of the SQL server is "Enabled", otherwise it is "False".

# SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG
# Values: "True" or "False"
# Description: Indicates if outbound network access is restricted. It is set to "True" if the restrictOutboundNetworkAccess property of the SQL server is not "Enable", otherwise it is "False".

# SQL_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG
# Values: "True" or "False"
# Description: Indicates if the Transport Layer Security (TLS) version is set to anything other than 1.2. It is set to "True" if the minimalTlsVersion property of the SQL server is not "1.2", otherwise it is "False".

# SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG
# Values: "True" or "False"
# Description: Indicates if there is a firewall rule that allows all IP addresses to access the SQL server. It is set to "True" if the firewall rule name is "allowAll" or if the start and end IP addresses of the firewall rule are "0.0.0.0" and "255.255.255.255" respectively, otherwise it is "False".

# SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG
# Values: "True" or "False"
# Description: Indicates if the firewall rule allows public ingress from any IP address that is not within private IP ranges (10.x.x.x, 172.16.x.x - 172.31.x.x, 192.168.x.x, and 127.x.x.x). It is set to "True" if the start IP address does not match these private ranges, otherwise it is "False".

# SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG
# Values: "True" or "False"
# Description: Indicates if the firewall rule allows all Windows Azure IPs to access the SQL server. It is set to "True" if the firewall rule name is "AllowAllWindowsAzureIps", otherwise it is "False".

# Include common constants and functions
source ./includes/common-constants.inc
source ./includes/common-functions.inc

# Function to output header based on CSV flag
function output_header() {
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Function to output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"SQL_SERVER_NAME\",\"SQL_SERVER_DOMAIN_NAME\",\"SQL_SERVER_TYPE\",\"SQL_SERVER_ENVIRONMENT\",\"SQL_SERVER_APPLICATION_CODE\",\"SQL_SERVER_APPLICATION_NAME\",\"SQL_SERVER_REQUESTOR_AD_ID\",\"SQL_SERVER_REQUESTOR_EMPLOYEE_ID\",\"SQL_SERVER_PUBLIC_NETWORK_ACCESS\",\"SQL_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"SQL_SERVER_ADMIN_LOGIN\",\"SQL_SERVER_ADMIN_TYPE\",\"SQL_SERVER_ADMIN_PRINCIPLE_TYPE\",\"SQL_SERVER_ADMIN_PRINCIPLE_LOGIN\",\"SQL_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"SQL_SERVER_TLS_VERSION\",\"SQL_SERVER_LOCATION\",\"SQL_SERVER_VERSION\",\"SQL_SERVER_FIREWALL_RULE_NAME\",\"SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"SQL_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"SQL_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}

# Function to output SQL server firewall rule in CSV format
function output_sql_server_firewall_rule_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$SQL_SERVER_NAME\",\"$SQL_SERVER_DOMAIN_NAME\",\"$SQL_SERVER_TYPE\",\"$SQL_SERVER_ENVIRONMENT\",\"$SQL_SERVER_APPLICATION_CODE\",\"$SQL_SERVER_APPLICATION_NAME\",\"$SQL_SERVER_REQUESTOR_AD_ID\",\"$SQL_SERVER_REQUESTOR_EMPLOYEE_ID\",\"$SQL_SERVER_PUBLIC_NETWORK_ACCESS\",\"$SQL_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"$SQL_SERVER_ADMIN_LOGIN\",\"$SQL_SERVER_ADMIN_TYPE\",\"$SQL_SERVER_ADMIN_PRINCIPLE_TYPE\",\"$SQL_SERVER_ADMIN_PRINCIPLE_LOGIN\",\"$SQL_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"$SQL_SERVER_TLS_VERSION\",\"$SQL_SERVER_LOCATION\",\"$SQL_SERVER_VERSION\",\"$SQL_SERVER_FIREWALL_RULE_NAME\",\"$SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"$SQL_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"$SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"$SQL_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"$SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"$SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"$SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"$SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
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
    echo "SQL Server Firewall Rule Name: $SQL_SERVER_FIREWALL_RULE_NAME"
    echo "SQL Server Firewall Rule Start IP Address: $SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS"
    echo "SQL Server Firewall Rule End IP Address: $SQL_SERVER_FIREWALL_RULE_END_IP_ADDRESS"
    echo "SQL Server Public Network Access Violation: $SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "SQL Server Outbound Network Access Violation: $SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "SQL Server Transport Layer Encryption Violation: $SQL_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG"
    echo "SQL Server Firewall Rule Allow All Public Ingress Violation: $SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG"
    echo "SQL Server Firewall Rule Allow Public Ingress Violation: $SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG"
    echo "SQL Server Firewall Rule Allow All Windows IP Violation: $SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG"
    echo "Whois Information: $SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT"
    echo $BLANK_LINE
}

function clear_sql_server_firewall_rule_variables() {
    SQL_SERVER_FIREWALL_RULE_NAME=""
    SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS=""
    SQL_SERVER_FIREWALL_RULE_END_IP_ADDRESS=""
    SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG=""
    SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG=""
    SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG=""
    SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=""
}

# Include common menu
source ./includes/common-menu.inc

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
output_debug_info "" "" "Subscriptions" "$SUBSCRIPTIONS";

check_if_subscriptions_exists "$SUBSCRIPTIONS"

output_header

echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do

    output_debug_info "" "" "Subscription" "$SUBSCRIPTION"
    
    # Parse subscription information
    parse_subscription "$SUBSCRIPTION"
    
    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME")
    output_debug_info "" "" "Resources Groups" "$RESOURCE_GROUPS"

    # Process each resource group
    if [[ $RESOURCE_GROUPS != "[]" ]]; then

        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do

            output_debug_info "" "" "Resources Group" "$RESOURCE_GROUP"   

            # Parse resource group information
            parse_resource_group "$RESOURCE_GROUP"
            
            # Get SQL servers for the resource group
            declare SQL_SERVERS=$(get_azure_sql_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Servers" "$SQL_SERVERS"

            # Process each SQL server
            if [[ $SQL_SERVERS != "[]" ]]; then
                echo $SQL_SERVERS | jq -rc '.[]' | while IFS='' read SQL_SERVER; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Server" "$SQL_SERVER"

                    # Parse SQL server information
                    parse_azure_sql_server "$SQL_SERVER"
                    
                    # Get firewall rules for the SQL server
                    declare SQL_SERVER_FIREWALL_RULES=$(get_azure_sql_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$SQL_SERVER_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Server Firewall Rules" "$SQL_SERVER_FIREWALL_RULES"

                    if [[ $SQL_SERVER_FIREWALL_RULES != "[]" ]]; then
                        echo $SQL_SERVER_FIREWALL_RULES | jq -rc '.[]' | while IFS='' read FIREWALL_RULE; do
                            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "SQL Server Firewall Rule" "$FIREWALL_RULE"
                            parse_azure_sql_server_firewall_rule "$FIREWALL_RULE"
                            output_sql_server_firewall_rule
                        done # End of firewall rule processing
                    else
                        clear_sql_server_firewall_rule_variables
                        output_sql_server_firewall_rule
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
