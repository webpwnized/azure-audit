#!/bin/bash

source ./parse-helper-functions.inc

# Function to parse subscription information
function parse_subscription() {
    local l_SUBSCRIPTION=$1
    SUBSCRIPTION_NAME=$(jq -rc '.displayName // ""' <<< "$l_SUBSCRIPTION")
    SUBSCRIPTION_STATE=$(jq -rc '.state // empty' <<< "$l_SUBSCRIPTION")
    SUBSCRIPTION_ID=$(jq -rc '.subscriptionId // ""' <<< "$l_SUBSCRIPTION")
}

# Function to parse resource group information
function parse_resource_group() {
    local l_RESOURCE_GROUP=$1

    # Parse resource group information from JSON
    RESOURCE_GROUP_NAME=$(jq -r '.name' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_LOCATION=$(jq -rc '.location // empty' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_APPLICATION_CODE=$(jq -r '.tags.applicationCode // ""' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(jq -r '.tags.departmentChargeCode // ""' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_PAR=$(jq -r '.tags.par // ""' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_REQUESTOR_AD_ID=$(jq -r '.tags.requestorAdId // ""' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(jq -r '.tags.requestorEmployeeId // ""' <<< "$l_RESOURCE_GROUP")
}

# Function to parse Network Security Group information
function parse_network_security_group() {
    local l_NETWORK_SECURITY_GROUP=$1;

    # Parse Network Security Group information from JSON
    NETWORK_SECURITY_GROUP_NAME=$(jq -rc '.name // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_LOCATION=$(jq -rc '.location // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_SECURITY_RULES=$(jq -rc '.securityRules // empty' <<< "$l_NETWORK_SECURITY_GROUP");
}

# Function to process role assignments
function parse_role_assignments() {
    l_ROLE_ASSIGNMENTS=$1

    # Initialize associative array to store unique members
    declare -A unique_members

    # Iterate through each role assignment using a while loop
    while IFS='' read -r ROLE_ASSIGNMENT; do
        
        output_debug_info "Role Assignment (JSON): $ROLE_ASSIGNMENT"

        PRINCIPLE_TYPE=$(jq -rc '.principalType // empty' <<< "$ROLE_ASSIGNMENT")
        ROLE_NAME=$(jq -rc '.roleDefinitionName // empty' <<< "$ROLE_ASSIGNMENT")
        
        if [[ $PRINCIPLE_TYPE == "User" ]]; then
            PRINCIPLE_NAME=$(jq -rc '.principalName // empty' <<< "$ROLE_ASSIGNMENT")
            unique_members["$PRINCIPLE_NAME"]=1  # Store unique user in the associative array
        elif [[ $PRINCIPLE_TYPE == "Group" ]]; then
            GROUP_NAME=$(jq -rc '.principalName // empty' <<< "$ROLE_ASSIGNMENT")
            GROUP_MEMBERS=$(get_group_members_serialized "$GROUP_NAME")

            # Split group members and add unique members to the associative array
            IFS=';' read -ra members_array <<< "$GROUP_MEMBERS"
            for member in "${members_array[@]}"; do
                unique_members["$member"]=1
            done
        fi
    done <<< "$(echo "$l_ROLE_ASSIGNMENTS" | jq -rc '.[]')"

    # Concatenate unique members from the associative array
    MEMBERS=""
    for member in "${!unique_members[@]}"; do
        MEMBERS+="$member;"
    done
}

# Function to parse Security Rule information
function parse_security_rule() {
    local l_SECURITY_RULE=$1;
    
	# Parse Security Rule information from JSON
	SECURITY_RULE_NAME=$(jq -r '.name // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_DESCRIPTION=$(jq -r '.description // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_ACCESS_CONTROL=$(jq -r '.access // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_DESTINATION_ADDRESS_PREFIX=$(jq -r '.destinationAddressPrefix // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_DESTINATION_ADDRESS_PREFIXES=$(jq -r '.destinationAddressPrefixes | join(", ") // empty' <<< "$l_SECURITY_RULE")
	SECURITY_RULE_DESTINATION_PORT_RANGE=$(jq -r '.destinationPortRange // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_DESTINATION_PORT_RANGES=$(jq -r '.destinationPortRanges | join(", ") // empty' <<< "$l_SECURITY_RULE")
	SECURITY_RULE_DIRECTION=$(jq -r '.direction // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_PROTOCOL=$(jq -r '.protocol // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_SOURCE_ADDRESS_PREFIX=$(jq -r '.sourceAddressPrefix // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_SOURCE_ADDRESS_PREFIXES=$(jq -r '.sourceAddressPrefixes | join(", ") // empty' <<< "$l_SECURITY_RULE")
	SECURITY_RULE_SOURCE_PORT_RANGE=$(jq -r '.sourcePortRange // empty' <<< "$l_SECURITY_RULE");
	SECURITY_RULE_SOURCE_PORT_RANGES=$(jq -r '.sourcePortRanges | join(", ") // empty' <<< "$l_SECURITY_RULE")

	# Initialize variables
	SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION="False"
	SECURITY_RULE_RDP_VIOLATION="False"
	SECURITY_RULE_SSH_VIOLATION="False"
	SECURITY_RULE_UDP_VIOLATION="False"
	SECURITY_RULE_HTTP_VIOLATION="False"
	SECURITY_RULE_SQL_SERVER_VIOLATION="False"

	# Check for each violation
	if [[ "$SECURITY_RULE_ACCESS_CONTROL" == "Allow" ]]; then
		if [[ "$SECURITY_RULE_DIRECTION" == "Inbound" ]]; then
			if is_traffic_allowed_from_internet; then
				SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "TCP" "3389"; then
				SECURITY_RULE_RDP_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "TCP" "22"; then
				SECURITY_RULE_SSH_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "UDP" "53" || 
			is_port_and_protocol_matched "UDP" "123" || 
			is_port_and_protocol_matched "UDP" "161" || 
			is_port_and_protocol_matched "UDP" "389" || 
			is_port_and_protocol_matched "UDP" "1900"; then
				SECURITY_RULE_UDP_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "TCP" "80" || 
			is_port_and_protocol_matched "TCP" "443"; then
				SECURITY_RULE_HTTP_VIOLATION="True"
			fi
			
			# Add violation for SQL Server (TCP port 1433)
			if is_port_and_protocol_matched "TCP" "1433"; then
				SECURITY_RULE_SQL_SERVER_VIOLATION="True"
			fi
        fi
	fi # end of if [[ "$SECURITY_RULE_ACCESS_CONTROL" == "Allow" ]]

	# Initialize SECURITY_RULE_VIOLATION as False
	SECURITY_RULE_VIOLATION="False"

	# Check if any violation is True
	if [[ "$SECURITY_RULE_RDP_VIOLATION" == "True" || 
		"$SECURITY_RULE_SSH_VIOLATION" == "True" || 
		"$SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION" == "True" || 
		"$SECURITY_RULE_UDP_VIOLATION" == "True" || 
		"$SECURITY_RULE_HTTP_VIOLATION" == "True" ||
		"$SECURITY_RULE_SQL_SERVER_VIOLATION" == "True" ]]; then
		SECURITY_RULE_VIOLATION="True"
	fi
}

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

    # Determine flags for public network access and outbound access violation
    SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False"
    [[ $SQL_SERVER_PUBLIC_NETWORK_ACCESS == "Enabled" ]] && SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True"

    SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG="False"
    [[ $SQL_SERVER_RESTRICT_OUTBOUND_ACCESS != "Enable" ]] && SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG="True"

    SQL_SERVER_SQLCMD_CONNECT=""
    if [[ $SQL_SERVER_SQLCMD_INSTALLED != "True" ]]; then
        SQL_SERVER_SQLCMD_CONNECT="Skipped Check: The sqlcmd software is not installed."
    elif [[ $SQL_SERVER_PUBLIC_NETWORK_ACCESS != "Enabled" ]]; then
        SQL_SERVER_SQLCMD_CONNECT="Skipped Check: Public network access is not enabled." 
    elif [[ $CHECK_CONNECTIVITY != "True" ]]; then
        SQL_SERVER_SQLCMD_CONNECT="Skipped Check: Connectivity check is not enabled by the user optional flag."
    else 
        SQL_SERVER_SQLCMD_CONNECT="$(sqlcmd -S $SQL_SERVER_DOMAIN_NAME -U $SQL_SERVER_ADMIN_LOGIN -P 'password')"
    fi

}

# Function to parse SQL server firewall rule information
function parse_azure_sql_server_firewall_rule() {
    local l_FIREWALL_RULE=$1

    # Parse SQL server firewall rule information from JSON
    FIREWALL_RULE_NAME=$(jq -rc '.name' <<< "$l_FIREWALL_RULE")
    FIREWALL_RULE_START_IP_ADDRESS=$(jq -rc '.startIpAddress // ""' <<< "$l_FIREWALL_RULE")
    FIREWALL_RULE_END_IP_ADDRESS=$(jq -rc '.endIpAddress // ""' <<< "$l_FIREWALL_RULE")
    FIREWALL_RULE_RESOURCE_GROUP=$(jq -rc '.resourceGroup // ""' <<< "$l_FIREWALL_RULE")
    
    # Determine flags for firewall rule violation
    FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="False"
    [[ $FIREWALL_RULE_NAME == "AllowAllWindowsAzureIps" ]] && FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="True"

    FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="False"
    if ! [[ $FIREWALL_RULE_START_IP_ADDRESS =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
        FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="True"
    fi

    FIREWALL_RULE_WHOIS_OUTPUT=""
    if [[ $WHOIS_INSTALLED != "True" ]]; then
        FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: The whois software is not installed."
    elif [[ $SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG != "True" ]]; then
        FIREWALL_RULE_WHOIS_OUTPUT="Skipped Check: Access from Internet is not allowed."
    else
        FIREWALL_RULE_WHOIS_OUTPUT=$(get_org_info_from_whois "$FIREWALL_RULE_START_IP_ADDRESS")
    fi
}
