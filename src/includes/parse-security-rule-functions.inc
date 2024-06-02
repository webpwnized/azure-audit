#!/bin/bash

# Function to check if traffic is allowed from the internet
function is_traffic_allowed_from_internet() {
    [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "*" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "0.0.0.0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "<nw>/0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "/0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Internet" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Any" ]]
}

function is_traffic_allowed_from_external_network() {
    [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" =~ ^(?!10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.).*$ ]]
}

# Function to check if the security rule matches a specific protocol and destination port
function is_port_and_protocol_matched() {
    local PROTOCOL="$1"
    local PORT="$2"

    # Check if protocol matches or is wildcard
    if [[ "$SECURITY_RULE_PROTOCOL" == "$PROTOCOL" || "$SECURITY_RULE_PROTOCOL" == "*" ]]; then
        # Check if single port or range of ports matches or is wildcard
        if [[ "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "$PORT" || 
              "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "*" ]]; then
            return 0
        fi
        
        # Check if the port is within the destination port ranges
        if [[ "$SECURITY_RULE_DESTINATION_PORT_RANGES" == *"$PORT"* ]]; then
            return 0
        fi
    fi

    return 1
}

function are_all_source_ports_allowed() {
	[[ "$SECURITY_RULE_SOURCE_PORT_RANGE" == "*" || 
	"$SECURITY_RULE_SOURCE_PORT_RANGES" == "*" ]]
}

function are_all_destination_ports_allowed() {
	[[ "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "*" || 
	"$SECURITY_RULE_DESTINATION_PORT_RANGES" == "*" ]]
}

# Function to parse Network Security Group information
function parse_network_security_group() {
    local l_NETWORK_SECURITY_GROUP=$1;

    # Parse Network Security Group information from JSON
    NETWORK_SECURITY_GROUP_NAME=$(jq -rc '.name // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_LOCATION=$(jq -rc '.location // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_SECURITY_RULES=$(jq -rc '.securityRules // empty' <<< "$l_NETWORK_SECURITY_GROUP");
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
	SECURITY_RULE_OPEN_FROM_EXTERNAL_NETWORK_VIOLATION="False" # Added to check if traffic
	SECURITY_RULE_RDP_VIOLATION="False"
	SECURITY_RULE_SSH_VIOLATION="False"
	SECURITY_RULE_UDP_VIOLATION="False"
	SECURITY_RULE_HTTP_VIOLATION="False"
	SECURITY_RULE_DATABASE_VIOLATION="False"
	SECURITY_RULE_FTP_VIOLATION="False"
	SECURITY_RULE_EMAIL_VIOLATION="False"
	SECURITY_RULE_ALL_SOURCE_PORTS_ALLOWED_VIOLATION="False"
	SECURITY_RULE_ALL_DESTINATION_PORTS_ALLOWED_VIOLATION="False"
	SECURITY_RULE_VIOLATION="False"

	# Check for each violation
	if [[ "$SECURITY_RULE_ACCESS_CONTROL" == "Allow" ]]; then
		if [[ "$SECURITY_RULE_DIRECTION" == "Inbound" ]]; then
			if is_traffic_allowed_from_internet; then
				SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION="True"
			fi

			if is_traffic_allowed_from_external_network; then
				SECURITY_RULE_OPEN_FROM_EXTERNAL_NETWORK_VIOLATION="True"
			fi

			if are_all_destination_ports_allowed; then
				SECURITY_RULE_ALL_DESTINATION_PORTS_ALLOWED_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "TCP" "3389"; then
				SECURITY_RULE_RDP_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "TCP" "22"; then
				SECURITY_RULE_SSH_VIOLATION="True"
			fi

			# Add violation for FTP
			if is_port_and_protocol_matched "TCP" "20" || 
			is_port_and_protocol_matched "TCP" "21"; then
				SECURITY_RULE_FTP_VIOLATION="True"
			fi

			# Add violation for Email (TCP port 25)
			if is_port_and_protocol_matched "TCP" "25" || 
			is_port_and_protocol_matched "TCP" "110" || 
			is_port_and_protocol_matched "TCP" "995"; then
				SECURITY_RULE_EMAIL_VIOLATION="True"
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
			if is_port_and_protocol_matched "TCP" "1433" || 
			is_port_and_protocol_matched "TCP" "1521" || 
   			is_port_and_protocol_matched "TCP" "3306" || 
   			is_port_and_protocol_matched "TCP" "5432"; then
				SECURITY_RULE_DATABASE_VIOLATION="True"
			fi
        fi # end of if [[ "$SECURITY_RULE_DIRECTION" == "Inbound" ]]

		if [[ "$SECURITY_RULE_DIRECTION" == "Outbound" ]]; then

			if are_all_source_ports_allowed; then
				SECURITY_RULE_ALL_SOURCE_PORTS_ALLOWED_VIOLATION="True"
			fi

			# Add violation for FTP
			if is_port_and_protocol_matched "TCP" "20" || 
			is_port_and_protocol_matched "TCP" "21"; then
				SECURITY_RULE_FTP_VIOLATION="True"
			fi

			# Add violation for Email (TCP port 25)
			if is_port_and_protocol_matched "TCP" "25" || 
			is_port_and_protocol_matched "TCP" "110" || 
			is_port_and_protocol_matched "TCP" "995"; then
				SECURITY_RULE_EMAIL_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "UDP" "53" || 
			is_port_and_protocol_matched "UDP" "123" || 
			is_port_and_protocol_matched "UDP" "161" || 
			is_port_and_protocol_matched "UDP" "389" || 
			is_port_and_protocol_matched "UDP" "1900"; then
				SECURITY_RULE_UDP_VIOLATION="True"
			fi

			if is_port_and_protocol_matched "TCP" "80"; then
				SECURITY_RULE_HTTP_VIOLATION="True"
			fi
			
			# Add violation for database ports
			if is_port_and_protocol_matched "TCP" "1433" || 
			is_port_and_protocol_matched "TCP" "1521" || 
   			is_port_and_protocol_matched "TCP" "3306" || 
   			is_port_and_protocol_matched "TCP" "5432"; then
				SECURITY_RULE_DATABASE_VIOLATION="True"
			fi
        fi # end of if [[ "$SECURITY_RULE_DIRECTION" == "Outbound" ]]

	fi # end of if [[ "$SECURITY_RULE_ACCESS_CONTROL" == "Allow" ]]

	# Check if any violation is True
	if [[ "$SECURITY_RULE_RDP_VIOLATION" == "True" || 
		"$SECURITY_RULE_SSH_VIOLATION" == "True" || 
		"$SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION" == "True" || 
		"$SECURITY_RULE_OPEN_FROM_EXTERNAL_NETWORK_VIOLATION" == "True" ||
		"$SECURITY_RULE_UDP_VIOLATION" == "True" || 
		"$SECURITY_RULE_HTTP_VIOLATION" == "True" || 
		"$SECURITY_RULE_FTP_VIOLATION" == "True" || 
		"$SECURITY_RULE_EMAIL_VIOLATION" == "True" || 
		"$SECURITY_RULE_DATABASE_VIOLATION" == "True" ]]; then
		SECURITY_RULE_VIOLATION="True"
	fi
}
