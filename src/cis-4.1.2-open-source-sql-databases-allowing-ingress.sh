#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql

# Debug: ./cis-4.1.2-azure-sql-databases-allowing-ingress.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

# Output Fields Documentation

# POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG
# Values: "True" or "False"
# Description: Indicates if public network access to the Database Server is enabled. It is set to "True" if the publicNetworkAccess property of the Database Server is "Enabled", otherwise it is "False".

# POSTGRES_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG
# Values: "True" or "False"
# Description: Indicates if outbound network access is restricted. It is set to "True" if the restrictOutboundNetworkAccess property of the Database Server is not "Enable", otherwise it is "False".

# POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG
# Values: "True" or "False"
# Description: Indicates if the Transport Layer Security (TLS) version is set to anything other than 1.2. It is set to "True" if the minimalTlsVersion property of the Database Server is not "1.2", otherwise it is "False".

# POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG
# Values: "True" or "False"
# Description: Indicates if there is a firewall rule that allows all IP addresses to access the Database Server. It is set to "True" if the firewall rule name is "allowAll" or if the start and end IP addresses of the firewall rule are "0.0.0.0" and "255.255.255.255" respectively, otherwise it is "False".

# POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG
# Values: "True" or "False"
# Description: Indicates if the firewall rule allows public ingress from any IP address that is not within private IP ranges (10.x.x.x, 172.16.x.x - 172.31.x.x, 192.168.x.x, and 127.x.x.x). It is set to "True" if the start IP address does not match these private ranges, otherwise it is "False".

# POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG
# Values: "True" or "False"
# Description: Indicates if the firewall rule allows all Windows Azure IPs to access the Database Server. It is set to "True" if the firewall rule name is "AllowAllWindowsAzureIps", otherwise it is "False".

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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"POSTGRES_SERVER_NAME\",\"POSTGRES_SERVER_DOMAIN_NAME\",\"POSTGRES_SERVER_TYPE\",\"POSTGRES_SERVER_ENVIRONMENT\",\"POSTGRES_SERVER_APPLICATION_CODE\",\"POSTGRES_SERVER_APPLICATION_NAME\",\"POSTGRES_SERVER_REQUESTOR_AD_ID\",\"POSTGRES_SERVER_REQUESTOR_EMPLOYEE_ID\",\"POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS\",\"POSTGRES_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"POSTGRES_SERVER_ADMIN_LOGIN\",\"POSTGRES_SERVER_ADMIN_TYPE\",\"POSTGRES_SERVER_ADMIN_PRINCIPLE_TYPE\",\"POSTGRES_SERVER_ADMIN_PRINCIPLE_LOGIN\",\"POSTGRES_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"POSTGRES_SERVER_TLS_VERSION\",\"POSTGRES_SERVER_LOCATION\",\"POSTGRES_SERVER_VERSION\",\"POSTGRES_SERVER_FIREWALL_RULE_NAME\",\"POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"POSTGRES_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}

# Function to output Database Server firewall rule in CSV format
function output_POSTGRES_SERVER_firewall_rule_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$POSTGRES_SERVER_NAME\",\"$POSTGRES_SERVER_DOMAIN_NAME\",\"$POSTGRES_SERVER_TYPE\",\"$POSTGRES_SERVER_ENVIRONMENT\",\"$POSTGRES_SERVER_APPLICATION_CODE\",\"$POSTGRES_SERVER_APPLICATION_NAME\",\"$POSTGRES_SERVER_REQUESTOR_AD_ID\",\"$POSTGRES_SERVER_REQUESTOR_EMPLOYEE_ID\",\"$POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS\",\"$POSTGRES_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"$POSTGRES_SERVER_ADMIN_LOGIN\",\"$POSTGRES_SERVER_ADMIN_TYPE\",\"$POSTGRES_SERVER_ADMIN_PRINCIPLE_TYPE\",\"$POSTGRES_SERVER_ADMIN_PRINCIPLE_LOGIN\",\"$POSTGRES_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"$POSTGRES_SERVER_TLS_VERSION\",\"$POSTGRES_SERVER_LOCATION\",\"$POSTGRES_SERVER_VERSION\",\"$POSTGRES_SERVER_FIREWALL_RULE_NAME\",\"$POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"$POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"$POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$POSTGRES_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"$POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}

# Function to output Database Server firewall rule
function output_POSTGRES_SERVER_firewall_rule() {
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_POSTGRES_SERVER_firewall_rule_helper
    fi
}

# Helper function to output Database Server firewall rule
function output_POSTGRES_SERVER_firewall_rule_helper() {
    if [[ $CSV == "True" ]]; then
        output_POSTGRES_SERVER_firewall_rule_csv
    else
        output_POSTGRES_SERVER_firewall_rule_text
    fi
}

# Function to output Database Server firewall rule in text format
function output_POSTGRES_SERVER_firewall_rule_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE"
    echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE"
    echo "Resource Group PAR: $RESOURCE_GROUP_PAR"
    echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID"
    echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID"
    echo "Database Server Name: $POSTGRES_SERVER_NAME"
    echo "Database Server Environment: $POSTGRES_SERVER_ENVIRONMENT"
    echo "Database Server Application Code: $POSTGRES_SERVER_APPLICATION_CODE"
    echo "Database Server Application Name: $POSTGRES_SERVER_APPLICATION_NAME"
    echo "Database Server Requestor AD ID: $POSTGRES_SERVER_REQUESTOR_AD_ID"
    echo "Database Server Employee ID: $POSTGRES_SERVER_REQUESTOR_EMPLOYEE_ID"
    echo "Database Server Domain Name: $POSTGRES_SERVER_DOMAIN_NAME"
    echo "Database Server Type: $POSTGRES_SERVER_TYPE"
    echo "Database Server Allows Public Network Access: $POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS"
    echo "Database Server Allow Outbound Access: $POSTGRES_SERVER_RESTRICT_OUTBOUND_ACCESS"
    echo "Database Server Login: $POSTGRES_SERVER_ADMIN_LOGIN"
    echo "Database Server Admin Type: $POSTGRES_SERVER_ADMIN_TYPE"
    echo "Database Server Admin Principle Type: $POSTGRES_SERVER_ADMIN_PRINCIPLE_TYPE"
    echo "Database Server Admin Principle Login: $POSTGRES_SERVER_ADMIN_PRINCIPLE_LOGIN"
    echo "Database Server Admin Requires Azure Login: $POSTGRES_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG"
    echo "Database Server TLS Version: $POSTGRES_SERVER_TLS_VERSION"
    echo "Database Server Location: $POSTGRES_SERVER_LOCATION"
    echo "Database Server Version: $POSTGRES_SERVER_VERSION"
    echo "Database Server Firewall Rule Name: $POSTGRES_SERVER_FIREWALL_RULE_NAME"
    echo "Database Server Firewall Rule Start IP Address: $POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS"
    echo "Database Server Firewall Rule End IP Address: $POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS"
    echo "Database Server Public Network Access Violation: $POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "Database Server Outbound Network Access Violation: $POSTGRES_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "Database Server Transport Layer Encryption Violation: $POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG"
    echo "Database Server Firewall Rule Allow All Public Ingress Violation: $POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG"
    echo "Database Server Firewall Rule Allow Public Ingress Violation: $POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG"
    echo "Database Server Firewall Rule Allow All Windows IP Violation: $POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG"
    echo "Whois Information: $POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT"
    echo $BLANK_LINE
}

# Include common menu
source ./common-menu.inc

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
output_debug_info "Subscriptions (JSON): $SUBSCRIPTIONS";

check_if_subscriptions_exists "$SUBSCRIPTIONS"

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
            
            # Get database servers for the resource group
            declare POSTGRES_SERVERS=$(get_postgres_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "Postgres Servers (JSON): $POSTGRES_SERVERS"

            # Process each database server
            if [[ $POSTGRES_SERVERS != "[]" ]]; then
                echo $POSTGRES_SERVERS | jq -rc '.[]' | while IFS='' read POSTGRES_SERVER; do
                    output_debug_info "Postgres Server (JSON): $POSTGRES_SERVER"

                    # Parse Database Server information
                    parse_postgres_server "$POSTGRES_SERVER"
                    
                    # Get firewall rules for the Database Server
                    declare POSTGRES_SERVER_FIREWALL_RULES=$(get_postgres_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$POSTGRES_SERVER_NAME")
                    output_debug_info "Postgres Server Firewall Rules (JSON): $POSTGRES_SERVER_FIREWALL_RULES"

                    if [[ $POSTGRES_SERVER_FIREWALL_RULES != "[]" ]]; then
                        echo $POSTGRES_SERVER_FIREWALL_RULES | jq -rc '.[]' | while IFS='' read FIREWALL_RULE; do
                            output_debug_info "Postgres Server Firewall Rule (JSON): $FIREWALL_RULE"
                            parse_postgres_server_firewall_rule "$FIREWALL_RULE"
                            output_postgres_server_firewall_rule
                        done # End of firewall rule processing
                    else
                        # Print message if no firewall rules found
                        output_user_info "No Database Server firewall rules found"
                    fi # End of firewall rule processing
                done # End of Database Server processing
            else
                # Print message if no database servers found
                output_user_info "No database servers found"
            fi # End of Database Server processing
        done # End of resource group processing
    else
        # Print message if no resource groups found
        output_user_info "No resource groups found"
    fi # End of resource group processing
done # End of subscription processing
