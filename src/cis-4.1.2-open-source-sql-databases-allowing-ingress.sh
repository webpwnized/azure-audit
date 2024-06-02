#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql

# Debug: ./cis-4.1.2-open-source-sql-databases-allowing-ingress.sh -s b09bcb9d-e055-4950-a9dd-2ab6002ef86c -r rg-dds-dev

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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"POSTGRES_SERVER_NAME\",\"POSTGRES_SERVER_TYPE\",\"POSTGRES_SERVER_LOCATION\",\"POSTGRES_SERVER_DOMAIN_NAME\",\"POSTGRES_SERVER_VERSION\",\"POSTGRES_SERVER_ADMIN_LOGIN\",\"POSTGRES_SERVER_TLS_ENFORCED\",\"POSTGRES_SERVER_FIREWALL_RULE_NAME\",\"POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}


# Function to output Database Server firewall rule in CSV format
function output_postgres_server_firewall_rule_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$POSTGRES_SERVER_NAME\",\"$POSTGRES_SERVER_TYPE\",\"$POSTGRES_SERVER_LOCATION\",\"$POSTGRES_SERVER_DOMAIN_NAME\",\"$POSTGRES_SERVER_VERSION\",\"$POSTGRES_SERVER_ADMIN_LOGIN\",\"$POSTGRES_SERVER_TLS_ENFORCED\",\"$POSTGRES_SERVER_FIREWALL_RULE_NAME\",\"$POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"$POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"$POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"$POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}

# Function to output Database Server firewall rule
function output_postgres_server_firewall_rule() {
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_postgres_server_firewall_rule_helper
    fi
}

# Helper function to output Database Server firewall rule
function output_postgres_server_firewall_rule_helper() {
    if [[ $CSV == "True" ]]; then
        output_postgres_server_firewall_rule_csv
    else
        output_postgres_server_firewall_rule_text
    fi
}

# Function to output Database Server firewall rule in text format
function output_postgres_server_firewall_rule_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE"
    echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE"
    echo "Resource Group PAR: $RESOURCE_GROUP_PAR"
    echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID"
    echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID"
    echo "Database Server Name: $POSTGRES_SERVER_NAME"
    echo "Database Server Type: $POSTGRES_SERVER_TYPE"
    echo "Database Server Location: $POSTGRES_SERVER_LOCATION"
    echo "Database Server Fully Qualified Domain Name (FQDN): $POSTGRES_SERVER_DOMAIN_NAME"
    echo "Database Server Version: $POSTGRES_SERVER_VERSION"
    echo "Database Server Admin Username: $POSTGRES_SERVER_ADMIN_LOGIN"
    echo "Database Server TLS Enforced: $POSTGRES_SERVER_TLS_ENFORCED"
    echo "Firewall Rule Name: $POSTGRES_SERVER_FIREWALL_RULE_NAME"
    echo "Firewall Rule Start IP Address: $POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS"
    echo "Firewall Rule End IP Address: $POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS"
    echo "Public Network Access Violation: $POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "Transport Layer Encryption Violation: $POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG"
    echo "Firewall Rule Allow Public Ingress Violation: $POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG"
    echo "Firewall Rule Allow All Public Ingress Violation: $POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG"
    echo "Firewall Rule Allow All Windows IP Violation: $POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG"
    echo "Whois Information: $POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT"
    echo $BLANK_LINE
}

function clear_postgres_server_firewall_rule_variables() {
    POSTGRES_SERVER_FIREWALL_RULE_NAME=""
    POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS=""
    POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS=""
    POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG=""
    POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG=""
    POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG=""
    POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=""
}

# Include common menu
source ./includes/common-menu.inc

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
                        done # End of firewall rule processing
                    else
                       clear_postgres_server_firewall_rule_variables
                    fi # End of firewall rule processing
                    output_postgres_server_firewall_rule
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
