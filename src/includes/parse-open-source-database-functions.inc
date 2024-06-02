#!/bin/bash

function parse_postgres_server() {
    local l_POSTGRES_SERVER=$1
    
    # Parse POSTGRES server information from JSON
    POSTGRES_SERVER_NAME=$(jq -rc '.name // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_APPLICATION_CODE=$(jq -rc '.tags.applicationCode // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_REQUESTOR_AD_ID=$(jq -rc '.tags.requestorAdId // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_REQUESTOR_EMPLOYEE_ID=$(jq -rc '.tags.requestorEmployeeId // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_ADMIN_LOGIN=$(jq -rc '.administratorLogin // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_DOMAIN_NAME=$(jq -rc '.fullyQualifiedDomainName // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_LOCATION=$(jq -rc '.location // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_TLS_VERSION=$(jq -rc '.minimalTlsVersion // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS=$(jq -rc '.publicNetworkAccess // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_TYPE=$(jq -rc '.type // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_VERSION=$(jq -rc '.version // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_TLS_ENFORCED=$(jq -rc '.sslEnforcement // ""' <<< "$l_POSTGRES_SERVER")

    # Initialize variables
    POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"
    POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG="False"
    
    # Determine flags for public network access and outbound access violation
    [[ $POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS == "Enabled" ]] && POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"
    [[ $POSTGRES_SERVER_TLS_VERSION != "1.2" ]] && POSTGRES_SERVER_TRANSPORT_LAYER_ENCRYPTION_VIOLATION_FLAG="True"
}

function parse_postgres_server_firewall_rule() {
    local l_POSTGRES_SERVER_FIREWALL_RULE=$1

    POSTGRES_SERVER_FIREWALL_RULE_NAME=$(jq -rc '.name // ""' <<< "$l_POSTGRES_SERVER_FIREWALL_RULE")
    POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS=$(jq -rc '.startIpAddress // ""' <<< "$l_POSTGRES_SERVER_FIREWALL_RULE")
    POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS=$(jq -rc '.endIpAddress // ""' <<< "$l_POSTGRES_SERVER_FIREWALL_RULE")
    POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="False"
    POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="False"
    POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="False"
    POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=""

    # Determine flags for firewall rule violation
    # The AllowAllWindowsAzureIps rule for Azure POSTGRES Server firewall rules means that the POSTGRES server is configured to allow incoming connections from all Azure services. When this rule is enabled, it allows traffic from any IP address within the Azure datacenter IP ranges.
    [[ $POSTGRES_SERVER_FIREWALL_RULE_NAME == "AllowAllWindowsAzureIps" ]] && POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="True"
    
    # The "allowAll" firewall rule in the context of Azure POSTGRES Server firewall rules typically refers to a rule that allows incoming connections from all IP addresses. This is not recommended.
    [[ $POSTGRES_SERVER_FIREWALL_RULE_NAME == "allowAll" ]] && POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="True"
    [[ $POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS == "0.0.0.0" && $POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS == "255.255.255.255" ]] && POSTGRES_SERVER_FIREWALL_RULE_ALLOW_ALL_PUBLIC_INGRESS_FLAG="True"

    if ! [[ $POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
        POSTGRES_SERVER_FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="True"
    fi

    if [[ $WHOIS_INSTALLED != "True" ]]; then
        POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: The whois software is not installed."
    elif [[ $POSTGRES_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG != "True" ]]; then
        POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: Access from Internet is not allowed."
    else
        POSTGRES_SERVER_FIREWALL_RULE_WHOIS_OUTPUT=$(get_org_info_from_whois "$POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS")
    fi




}
