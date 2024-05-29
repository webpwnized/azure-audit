#!/bin/bash

# Output debug information
function output_debug_info() {
    # Check if debug mode is enabled
    if [[ $DEBUG == "True" && $CSV == "False" ]]; then
        echo "$1"
        echo $BLANK_LINE
    fi
}

# Output message to user
function output_user_info() {
    # Check if debug mode is enabled
    if [[ $CSV == "False" ]]; then
        echo "$1"
        echo $BLANK_LINE
    fi
}

# Function to encode output for use in CSV files
function encode_for_csv() {
    local input="$1"
    local output="$input"

    # Escape double quotes by replacing them with two double quotes
    output="${output//\"/\"\"}"

    # If the string contains commas, double quotes, or newlines, wrap it in double quotes
    if [[ "$output" =~ [,\"$'\n'] ]]; then
        output="\"$output\""
    fi

    echo "$output"
}

function get_org_info_from_whois() {
    local ip_address="$1"
    local whois_output
    local org_name
    local org_country

    whois_output=$(whois "$ip_address")
    
    org_name=$(echo "$whois_output" | grep -i 'org-name\|OrgName\|Organization' | head -n 1 | awk -F: '{print $2}' | xargs)
    org_description=$(echo "$whois_output" | grep -i 'desc' | head -n 1 | awk -F: '{print $2}' | xargs)
    org_country=$(echo "$whois_output" | grep -i 'country' | head -n 1 | awk -F: '{print $2}' | xargs)
    
    # If the output is empty, assign a default value
    org_name="${org_name:-Unknown}"
    org_description="${org_description:-Unknown}"
    org_country="${org_country:-Unknown}"
    
    # Encode for CSV and combine results
    local encoded_org_name
    local encoded_org_description
    local encoded_org_country
    encoded_org_name=$(encode_for_csv "$org_name")
    encoded_org_description=$(encode_for_csv "$org_description")
    encoded_org_country=$(encode_for_csv "$org_country")
    
    echo "$encoded_org_name ($encoded_org_country) - $encoded_org_description"
}

# Function to get subscriptions
function get_subscriptions() {
    local l_SUBSCRIPTION_ID="$1"
    local l_RESULTS=""

    if [[ $l_SUBSCRIPTION_ID == "" ]]; then
        # Get all subscriptions if no specific subscription ID provided
        l_RESULTS=$(az account subscription list --output="json")
    else
        # Get specific subscription by ID
        l_RESULTS=$(az account subscription list --query "[?subscriptionId=='$l_SUBSCRIPTION_ID']" --output="json")
    fi

    echo "$l_RESULTS"
}

# Function to parse subscription information
function parse_subscription() {
    local l_SUBSCRIPTION=$1
    SUBSCRIPTION_NAME=$(jq -rc '.displayName // ""' <<< "$l_SUBSCRIPTION")
    SUBSCRIPTION_STATE=$(jq -rc '.state // empty' <<< "$l_SUBSCRIPTION")
    SUBSCRIPTION_ID=$(jq -rc '.subscriptionId // ""' <<< "$l_SUBSCRIPTION")
}

# Function to get resource groups
function get_resource_groups() {
    local l_SUBSCRIPTION_ID="$1"
    local l_RESOURCE_GROUP_NAME="$2"
    local l_RESULTS=""

    if [[ $l_RESOURCE_GROUP_NAME == "" ]]; then
        # Get all resource groups if no specific resource group name provided
        l_RESULTS=$(az group list --output="json" --subscription="$l_SUBSCRIPTION_ID" 2>/dev/null)
    else
        # Get specific resource group by name
        l_RESULTS=$(az group list --output="json" --subscription="$l_SUBSCRIPTION_ID" --query "[?name=='$l_RESOURCE_GROUP_NAME']" 2>/dev/null)
    fi

    echo "$l_RESULTS"
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

# Function to get Network Security Groups
# Example: declare NSGS=$(get_network_security_groups "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME");
function get_network_security_groups() {
    local l_SUBSCRIPTION_ID="$1"
    local l_RESOURCE_GROUP_NAME="$2"
    
    # Get Security Rules
    az network nsg list \
        --output="json" \
        --subscription="$l_SUBSCRIPTION_ID" \
        --resource-group="$l_RESOURCE_GROUP_NAME" \
        2>/dev/null  \
        | jq -r 'map({ name: .name, location: .location, securityRules: (.securityRules | map(del(.etag))) })'
}

# Function to parse Network Security Group information
function parse_network_security_group() {
    local l_NETWORK_SECURITY_GROUP=$1;

    # Parse Network Security Group information from JSON
    NETWORK_SECURITY_GROUP_NAME=$(jq -rc '.name // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_LOCATION=$(jq -rc '.location // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_SECURITY_RULES=$(jq -rc '.securityRules // empty' <<< "$l_NETWORK_SECURITY_GROUP");
}

# Function to get members of a group
function get_group_members() {
    local l_GROUP_NAME="$1"
    
    # Get group members
    az ad group member list --group "$GROUP_NAME" --output="json"
}

# Function to get members of a group and serialize the emails
function get_group_members_serialized() {
    local l_GROUP_NAME="$1"
    local l_EMAILS=""
    local l_PRINCIPLE_EMAIL=""

    # Get group members and extract email addresses
    l_GROUP_MEMBERS=$(az ad group member list --group "$l_GROUP_NAME" --query "[].mail" --output="json" 2>/dev/null)
    
    # Iterate over each member's email address
    for l_MEMBER in $(echo "$l_GROUP_MEMBERS" | jq -r '.[]'); do
        if [[ $l_MEMBER != "" ]]; then
            l_MEMBERS="$l_MEMBERS$l_MEMBER;"
        fi
    done

    echo "$l_MEMBERS"
}

# Function to get role assignments for a subscription
function get_subscription_role_assignments() {
    local l_SUBSCRIPTION_NAME="$1"
    
    # Get subscription role assignments
    az role assignment list --subscription "$l_SUBSCRIPTION_NAME" --output="json" 2>/dev/null
}

# Function to get role assignments for a resource group
function get_resource_group_role_assignments() {
    local l_SUBSCRIPTION_NAME="$1"
    local l_RESOURCE_GROUP_NAME="$2"

    # Get resource group role assignments
    az role assignment list \
        --subscription "$l_SUBSCRIPTION_NAME" \
        --resource-group "$l_RESOURCE_GROUP_NAME" \
        --output="json"
}

# Function to get and process role assignments
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

# Function to check if traffic is allowed from the internet
function is_traffic_allowed_from_internet() {
    [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" =~ ^(?!10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.).*$ || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "*" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "0.0.0.0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "<nw>/0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "/0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Internet" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Any" ]]
}

# Function to check if the security rule matches a specific protocol and destination port
function is_port_and_protocol_matched() {
    [[ "$SECURITY_RULE_PROTOCOL" == "$1" || "$SECURITY_RULE_PROTOCOL" == "*" ]] && 
    [[ "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "$2" || "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "*" || "$SECURITY_RULE_DESTINATION_PORT_RANGES" == *"$2"* ]]
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

# Function to get Azure SQL servers
function get_azure_sql_servers() {
    local l_SUBSCRIPTION_ID="$1"
    local l_RESOURCE_GROUP_NAME="$2"
    
    # Get Azure SQL servers
    az sql server list \
        --output="json" \
        --subscription="$l_SUBSCRIPTION_ID" \
        --resource-group="$l_RESOURCE_GROUP_NAME" 2>/dev/null
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

# Function to get Azure SQL server firewall rules
function get_azure_sql_server_firewall_rules() {
    local l_SUBSCRIPTION_ID="$1"
    local l_RESOURCE_GROUP_NAME="$2"
    local l_SQL_SERVER_NAME="$3"
    
    # Get Azure SQL server firewall rules
    az sql server firewall-rule list \
        --subscription="$l_SUBSCRIPTION_ID" \
        --resource-group="$l_RESOURCE_GROUP_NAME" \
        --server="$l_SQL_SERVER_NAME" \
        --output="json" 2>/dev/null
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



