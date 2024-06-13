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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"DATABASE_SERVER_NAME\",\"DATABASE_SERVER_DOMAIN_NAME\",\"DATABASE_SERVER_TYPE\",\"DATABASE_SERVER_LOCATION\",\"DATABASE_SERVER_VERSION\",\"DATABASE_SERVER_ADMIN_LOGIN\",\"DATABASE_SERVER_TLS_ENFORCED\",\"DATABASE_SERVER_TLS_VERSION\",\"DATABASE_SERVER_FIREWALL_RULE_NAME\",\"DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"DATABASE_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"DATABASE_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"DATABASE_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"DATABASE_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}


# Function to output Database Server firewall rule in CSV format
function output_database_server_firewall_rule_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$DATABASE_SERVER_NAME\",\"$DATABASE_SERVER_DOMAIN_NAME\",\"$DATABASE_SERVER_TYPE\",\"$DATABASE_SERVER_LOCATION\",\"$DATABASE_SERVER_VERSION\",\"$DATABASE_SERVER_ADMIN_LOGIN\",\"$DATABASE_SERVER_TLS_ENFORCED\",\"$DATABASE_SERVER_TLS_VERSION\",\"$DATABASE_SERVER_FIREWALL_RULE_NAME\",\"$DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS\",\"$DATABASE_SERVER_FIREWALL_RULE_END_IP_ADDRESS\",\"$DATABASE_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$DATABASE_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG\",\"$DATABASE_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\",\"$DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG\",\"$DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"$DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT\""
}

# Function to output Database Server firewall rule
function output_database_server_firewall_rule() {
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_database_server_firewall_rule_helper
    fi
}

# Helper function to output Database Server firewall rule
function output_database_server_firewall_rule_helper() {
    if [[ $CSV == "True" ]]; then
        output_database_server_firewall_rule_csv
    else
        output_database_server_firewall_rule_text
    fi
}

# Function to output Database Server firewall rule in text format
function output_database_server_firewall_rule_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE"
    echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE"
    echo "Resource Group PAR: $RESOURCE_GROUP_PAR"
    echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID"
    echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID"
    echo "Database Server Name: $DATABASE_SERVER_NAME"
    echo "Database Server Fully Qualified Domain Name (FQDN): $DATABASE_SERVER_DOMAIN_NAME"
    echo "Database Server Type: $DATABASE_SERVER_TYPE"
    echo "Database Server Location: $DATABASE_SERVER_LOCATION"
    echo "Database Server Version: $DATABASE_SERVER_VERSION"
    echo "Database Server Admin Username: $DATABASE_SERVER_ADMIN_LOGIN"
    echo "Database Server TLS Enforced: $DATABASE_SERVER_TLS_ENFORCED"
    echo "Database Server TLS Version: $DATABASE_SERVER_TLS_VERSION"
    echo "Firewall Rule Name: $DATABASE_SERVER_FIREWALL_RULE_NAME"
    echo "Firewall Rule Start IP Address: $DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS"
    echo "Firewall Rule End IP Address: $DATABASE_SERVER_FIREWALL_RULE_END_IP_ADDRESS"
    echo "Public Network Access Violation: $DATABASE_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "Transport Layer Encryption Violation: $DATABASE_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG"
    echo "Firewall Rule Allow Public Ingress Violation: $DATABASE_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG"
    echo "Firewall Rule Allow All Public Ingress Violation: $DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG"
    echo "Firewall Rule Allow All Windows IP Violation: $DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG"
    echo "Whois Information: $DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT"
    echo $BLANK_LINE
}

function clear_database_server_firewall_rule_variables() {
    DATABASE_SERVER_FIREWALL_RULE_NAME=""
    DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS=""
    DATABASE_SERVER_FIREWALL_RULE_END_IP_ADDRESS=""
    DATABASE_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG=""
    DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG=""
    DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG=""
    DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=""
}

function process_postgres_databses() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2

    # Get database servers for the resource group
    declare DATABASE_SERVERS=$(get_postgres_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Servers" "$DATABASE_SERVERS"

    process_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVERS" "Postgres"
}

function process_postgres_flexible_databases() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2

    # Get database servers for the resource group
    declare DATABASE_SERVERS=$(get_postgres_flexible_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Postgres Flexible Servers" "$DATABASE_SERVERS"

    process_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVERS" "PostgresFlexible"
}

function process_maridb_databses() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2

    # Get database servers for the resource group
    declare DATABASE_SERVERS=$(get_mariadb_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "MariaDB Servers" "$DATABASE_SERVERS"

    process_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVERS" "MariaDB"
}

function process_mysql_databses() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2

    # Get database servers for the resource group
    declare DATABASE_SERVERS=$(get_mysql_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "MySQL Servers" "$DATABASE_SERVERS"

    process_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVERS" "MySQL"
}

function process_mysql_flexible_databses() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2

    # Get database servers for the resource group
    declare DATABASE_SERVERS=$(get_mysql_flexible_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "MySQL Flexible Servers" "$DATABASE_SERVERS"

    process_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVERS" "MySQLFlexible"
}

function process_mssql_databses() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2

    # Get database servers for the resource group
    declare DATABASE_SERVERS=$(get_azure_sql_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "MSSQL Servers" "$DATABASE_SERVERS"

    process_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVERS" "MSSQL"
}

function process_databases() {
    local SUBSCRIPTION_NAME=$1
    local RESOURCE_GROUP_NAME=$2
    local DATABASE_SERVERS=$3
    local DATABASE_TYPE=$4
    local DATABASE_SERVER_FIREWALL_RULES=""
    
    # Process each database server
    if [[ $DATABASE_SERVERS != "[]" ]]; then
        echo $DATABASE_SERVERS | jq -rc '.[]' | while IFS='' read DATABASE_SERVER; do
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_TYPE Server" "$DATABASE_SERVER"

            # Parse Database Server information
            parse_database_server "$DATABASE_SERVER"
            
            # Get firewall rules for the Database Server
            if [[ $DATABASE_TYPE == "Postgres" ]]; then
                DATABASE_SERVER_FIREWALL_RULES=$(get_postgres_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVER_NAME")
            elif [[ $DATABASE_TYPE == "PostgresFlexible" ]]; then
                DATABASE_SERVER_FIREWALL_RULES=$(get_postgres_flexible_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVER_NAME")
            elif [[ $DATABASE_TYPE == "MariaDB" ]]; then
                DATABASE_SERVER_FIREWALL_RULES=$(get_mariadb_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVER_NAME")
            elif [[ $DATABASE_TYPE == "MySQL" ]]; then
                DATABASE_SERVER_FIREWALL_RULES=$(get_mysql_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVER_NAME")
            elif [[ $DATABASE_TYPE == "MySQLFlexible" ]]; then
                DATABASE_SERVER_FIREWALL_RULES=$(get_mysql_flexible_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVER_NAME")
            elif [[ $DATABASE_TYPE == "MSSQL" ]]; then
                DATABASE_SERVER_FIREWALL_RULES=$(get_azure_sql_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_SERVER_NAME")
            fi
            
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_TYPE Server Firewall Rules" "$DATABASE_SERVER_FIREWALL_RULES"

            if [[ $DATABASE_SERVER_FIREWALL_RULES != "[]" ]]; then
                echo $DATABASE_SERVER_FIREWALL_RULES | jq -rc '.[]' | while IFS='' read FIREWALL_RULE; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$DATABASE_TYPE Server Firewall Rule" "$FIREWALL_RULE"
                    parse_database_server_firewall_rule "$FIREWALL_RULE"
                    output_database_server_firewall_rule
                done # End of firewall rule processing
            else
                clear_database_server_firewall_rule_variables
                output_database_server_firewall_rule
            fi # End of firewall rule processing
        done # End of Database Server processing
    else
        # Print message if no database servers found
        output_user_info "No database servers found"
    fi # End of Database Server processing
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

            output_debug_info "" "" "Resource Group" "$RESOURCE_GROUP"   

            # Parse resource group information
            parse_resource_group "$RESOURCE_GROUP"

            # Get Database Servers for the Resource Group
            process_postgres_databses "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME"
            process_postgres_flexible_databases "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME"
            process_maridb_databses "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME"
            process_mysql_databses "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME"
            process_mysql_flexible_databses "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME"
            process_mssql_databses "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME"
            
        done # End of resource group processing
    else
        # Print message if no resource groups found
        output_user_info "No resource groups found"
    fi # End of resource group processing
done # End of subscription processing
