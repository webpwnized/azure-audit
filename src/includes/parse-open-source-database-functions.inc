#!/bin/bash

function parse_database_server() {
    local l_DATABASE_SERVER=$1

    # Parse DATABASE server information from JSON
    DATABASE_SERVER_NAME=$(jq -rc '.name // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_APPLICATION_CODE=$(jq -rc '.tags.applicationCode // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_REQUESTOR_AD_ID=$(jq -rc '.tags.requestorAdId // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_REQUESTOR_EMPLOYEE_ID=$(jq -rc '.tags.requestorEmployeeId // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_ADMIN_LOGIN=$(jq -rc '.administratorLogin // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_DOMAIN_NAME=$(jq -rc '.fullyQualifiedDomainName // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_LOCATION=$(jq -rc '.location // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_TLS_VERSION=$(jq -rc '.minimalTlsVersion // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_PUBLIC_NETWORK_ACCESS=$(jq -rc '.publicNetworkAccess // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_TYPE=$(jq -rc '.type // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_VERSION=$(jq -rc '.version // ""' <<< "$l_DATABASE_SERVER")
    DATABASE_SERVER_TLS_ENFORCED=$(jq -rc '.sslEnforcement // ""' <<< "$l_DATABASE_SERVER")

    # Initialize variables
    DATABASE_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"
    DATABASE_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG="False"
    
    # Determine flags for public network access and outbound access violation
    [[ $DATABASE_SERVER_PUBLIC_NETWORK_ACCESS == "Enabled" ]] && DATABASE_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    [[ $DATABASE_SERVER_TLS_VERSION != "1.2" ]] && DATABASE_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG="True"
}

function parse_database_server_firewall_rule() {
    local l_DATABASE_SERVER_FIREWALL_RULE=$1

    DATABASE_SERVER_FIREWALL_RULE_NAME=$(jq -rc '.name // ""' <<< "$l_DATABASE_SERVER_FIREWALL_RULE")
    DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS=$(jq -rc '.startIpAddress // ""' <<< "$l_DATABASE_SERVER_FIREWALL_RULE")
    DATABASE_SERVER_FIREWALL_RULE_END_IP_ADDRESS=$(jq -rc '.endIpAddress // ""' <<< "$l_DATABASE_SERVER_FIREWALL_RULE")
    DATABASE_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="False"
    DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="False"
    DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="False"
    DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=""

    # Determine flags for firewall rule violation
    # The AllowAllWindowsAzureIps rule for Azure DATABASE Server firewall rules means that the DATABASE server is configured to allow incoming connections from all Azure services. When this rule is enabled, it allows traffic from any IP address within the Azure datacenter IP ranges.
    [[ $DATABASE_SERVER_FIREWALL_RULE_NAME == "AllowAllWindowsAzureIps" ]] && DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="True"
    
    # The "allowAll" firewall rule in the context of Azure DATABASE Server firewall rules typically refers to a rule that allows incoming connections from all IP addresses. This is not recommended.
    [[ $DATABASE_SERVER_FIREWALL_RULE_NAME == "allowAll" ]] && DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="True"
    [[ $DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS == "0.0.0.0" && $DATABASE_SERVER_FIREWALL_RULE_END_IP_ADDRESS == "255.255.255.255" ]] && DATABASE_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="True"

    if ! [[ $DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
        DATABASE_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="True"
    fi

    if [[ $WHOIS_INSTALLED != "True" ]]; then
        DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: The whois software is not installed."
    elif [[ $DATABASE_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG != "True" ]]; then
        DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: Access from Internet is not allowed."
    else
        DATABASE_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=$(get_org_info_from_whois "$DATABASE_SERVER_FIREWALL_RULE_START_IP_ADDRESS")
    fi




}
