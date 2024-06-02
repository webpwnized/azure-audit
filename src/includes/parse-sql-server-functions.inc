#!/bin/bash

# Function to parse SQL server information
function parse_azure_sql_server() {
    local l_SQL_SERVER=$1
    
    # Parse SQL server information from JSON
    SQL_SERVER_NAME=$(jq -rc '.name // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_ENVIRONMENT=$(jq -rc '.tags.Environment // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_APPLICATION_CODE=$(jq -rc '.tags.applicationCode // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_APPLICATION_NAME=$(jq -rc '.tags.applicationName // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_REQUESTOR_AD_ID=$(jq -rc '.tags.requestorADID // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_REQUESTOR_EMPLOYEE_ID=$(jq -rc '.tags.requestorEmployeeID // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_ADMIN_LOGIN=$(jq -rc '.administratorLogin // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_ADMIN_TYPE=$(jq -rc '.administrators.administratorType // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_ADMIN_PRINCIPLE_TYPE=$(jq -rc '.administrators.principalType // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_ADMIN_PRINCIPLE_LOGIN=$(jq -rc '.administrators.login // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_ADMIN_AZURE_LOGIN_ENABLED_FLAG=$(jq -rc '.administrators.azureAdOnlyAuthentication // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_DOMAIN_NAME=$(jq -rc '.fullyQualifiedDomainName // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_LOCATION=$(jq -rc '.location // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_TLS_VERSION=$(jq -rc '.minimalTlsVersion // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_PUBLIC_NETWORK_ACCESS=$(jq -rc '.publicNetworkAccess // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_RESTRICT_OUTBOUND_ACCESS=$(jq -rc '.restrictOutboundNetworkAccess // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_TYPE=$(jq -rc '.type // ""' <<< "$l_SQL_SERVER")
    SQL_SERVER_VERSION=$(jq -rc '.version // ""' <<< "$l_SQL_SERVER")

    # Initialize variables
    SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"
    SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG="False"
    SQL_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG="False"
    
    # Determine flags for public network access and outbound access violation
    [[ $SQL_SERVER_PUBLIC_NETWORK_ACCESS == "Enabled" ]] && SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    [[ $SQL_SERVER_RESTRICT_OUTBOUND_ACCESS != "Enable" ]] && SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG="True"
    [[ $SQL_SERVER_TLS_VERSION != "1.2" ]] && SQL_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG="True"
}

# Function to parse SQL server firewall rule information
function parse_azure_sql_server_firewall_rule() {
    local l_SQL_SERVER_FIREWALL_RULE=$1

    # Parse SQL server firewall rule information from JSON
    SQL_SERVER_FIREWALL_RULE_NAME=$(jq -rc '.name' <<< "$l_SQL_SERVER_FIREWALL_RULE")
    SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS=$(jq -rc '.startIpAddress // ""' <<< "$l_SQL_SERVER_FIREWALL_RULE")
    SQL_SERVER_FIREWALL_RULE_END_IP_ADDRESS=$(jq -rc '.endIpAddress // ""' <<< "$l_SQL_SERVER_FIREWALL_RULE")
    SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="False"
    SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="False"
    SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="False"
    SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=""
    
    # Determine flags for firewall rule violation
    # The AllowAllWindowsAzureIps rule for Azure SQL Server firewall rules means that the SQL server is configured to allow incoming connections from all Azure services. When this rule is enabled, it allows traffic from any IP address within the Azure datacenter IP ranges.
    [[ $SQL_SERVER_FIREWALL_RULE_NAME == "AllowAllWindowsAzureIps" ]] && SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="True"
    
    # The "allowAll" firewall rule in the context of Azure SQL Server firewall rules typically refers to a rule that allows incoming connections from all IP addresses. This is not recommended.
    [[ $SQL_SERVER_FIREWALL_RULE_NAME == "allowAll" ]] && SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="True"
    [[ $SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS == "0.0.0.0" && $SQL_SERVER_FIREWALL_RULE_END_IP_ADDRESS == "255.255.255.255" ]] && SQL_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="True"

    if ! [[ $SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
        SQL_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="True"
    fi

    if [[ $WHOIS_INSTALLED != "True" ]]; then
        SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: The whois software is not installed."
    elif [[ $SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG != "True" ]]; then
        SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: Access from Internet is not allowed."
    else
        SQL_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=$(get_org_info_from_whois "$SQL_SERVER_FIREWALL_RULE_START_IP_ADDRESS")
    fi
}
