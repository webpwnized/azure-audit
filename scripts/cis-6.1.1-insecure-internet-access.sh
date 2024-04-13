#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql

# Debug: ./cis-6.1.1-insecure-internet-access.sh -s 1014e3e6-e0cf-44c0-8efe-ba17d0c6e3ed -r rg-scd-prd

# Include common constants and functions
source ./common-constants.inc;
source ./functions.inc;

# Function to output header based on CSV flag
function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header
	fi
}

# Function to output Security Rule firewall rule
function output_security_rule() {
	if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
		output_security_rule_helper;
	fi;
};

# Helper function to output Security Rule firewall rule
function output_security_rule_helper() {
	if [[ $CSV == "True" ]]; then
		output_security_rule_csv;
	else
		output_security_rule_text;
	fi;
};

# Function to output Source Address Prefix
function output_source_address_prefix() {
    if [[ -n "$SECURITY_RULE_SOURCE_ADDRESS_PREFIXES" ]]; then
        echo "Source Address Prefixes: $SECURITY_RULE_SOURCE_ADDRESS_PREFIXES"
    else
        echo "Source Address Prefix: $SECURITY_RULE_SOURCE_ADDRESS_PREFIX"
    fi
}

# Function to output Source Port Ranges
function output_source_port_ranges() {
    if [[ -n "$SECURITY_RULE_SOURCE_PORT_RANGES" ]]; then
        echo "Source Port Ranges: $SECURITY_RULE_SOURCE_PORT_RANGES"
    else
        echo "Source Port Range: $SECURITY_RULE_SOURCE_PORT_RANGE"
    fi
}

# Function to output Destination Address Prefix
function output_destination_address_prefix() {
    if [[ -n "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIXES" ]]; then
        echo "Destination Address Prefixes: $SECURITY_RULE_DESTINATION_ADDRESS_PREFIXES"
    else
        echo "Destination Address Prefix: $SECURITY_RULE_DESTINATION_ADDRESS_PREFIX"
    fi
}

# Function to output Destination Port Ranges
function output_destination_port_ranges() {
    if [[ -n "$SECURITY_RULE_DESTINATION_PORT_RANGES" ]]; then
        echo "Destination Port Ranges: $SECURITY_RULE_DESTINATION_PORT_RANGES"
    else
        echo "Destination Port Range: $SECURITY_RULE_DESTINATION_PORT_RANGE"
    fi
}

# Function to output Virtual Network Note and Other Notes
function output_notes() {
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "VirtualNetwork" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "VirtualNetwork" ]]; then
        echo "Note: VirtualNetwork means that traffic is allowed from all resources within the same virtual network."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureLoadBalancer" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureLoadBalancer" ]]; then
        echo "Note: AzureLoadBalancer means that traffic is allowed from Azure Load Balancer."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "CorpNetPublic" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "CorpNetPublic" ]]; then
        echo "Note: CorpNetPublic means that traffic is allowed from a public IP range associated with the organization's corporate network."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "CorpNetSaw" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "CorpNetSaw" ]]; then
        echo "Note: CorpNetSaw means that traffic is allowed from a subnet associated with the organization's corporate network."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Internet" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "Internet" ]]; then
        echo "Note: Internet means that traffic is allowed from or to the Internet."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Any" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "Any" ]]; then
        echo "Note: Any means that traffic is allowed from or to any source or destination."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "/0" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "/0" ]]; then
        echo "Note: /0 means that traffic is allowed from or to any source or destination IP address."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "0.0.0.0" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "0.0.0.0" ]]; then
        echo "Note: 0.0.0.0 means that traffic is allowed from or to any IP address."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Sqlmanagement" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "Sqlmanagement" ]]; then
        echo "Note: Sqlmanagement represents traffic from or to Azure SQL Management services."
    fi
    
    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureCloud" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureCloud" ]]; then
        echo "Note: AzureCloud represents traffic from or to Azure Cloud infrastructure."
    fi
}

# Function to output CSV header
function output_csv_header() {
    cat <<EOF
"SUBSCRIPTION_NAME","RESOURCE_GROUP_NAME","RESOURCE_GROUP_LOCATION","RESOURCE_GROUP_APPLICATION_CODE","RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE","RESOURCE_GROUP_PAR","RESOURCE_GROUP_REQUESTOR_AD_ID","RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID","NETWORK_SECURITY_GROUP_NAME","NETWORK_SECURITY_GROUP_LOCATION","VIOLATION","OPEN_FROM_INTERNET_VIOLATION","RDP_VIOLATION","SSH_VIOLATION","SQL_SERVER_VIOLATION","HTTP_VIOLATION","UDP_VIOLATION","SECURITY_RULE_NAME","SECURITY_RULE_DESCRIPTION","SECURITY_RULE_ACCESS_CONTROL","SECURITY_RULE_DIRECTION","SECURITY_RULE_PROTOCOL","SOURCE_ADDRESS_PREFIX","SOURCE_PORT_RANGES","DESTINATION_ADDRESS_PREFIX","DESTINATION_PORT_RANGES","NOTES"
EOF
}

# Function to output Security Rule firewall rule in CSV format
function output_security_rule_csv() {
    echo -n "\"$SUBSCRIPTION_NAME\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_LOCATION\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$NETWORK_SECURITY_GROUP_NAME\",\"$NETWORK_SECURITY_GROUP_LOCATION\",\"$SECURITY_RULE_VIOLATION\",\"$SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION\",\"$SECURITY_RULE_RDP_VIOLATION\",\"$SECURITY_RULE_SSH_VIOLATION\",\"$SECURITY_RULE_SQL_SERVER_VIOLATION\",\"$SECURITY_RULE_HTTP_VIOLATION\",\"$SECURITY_RULE_UDP_VIOLATION\",\"$SECURITY_RULE_NAME\",\"$SECURITY_RULE_DESCRIPTION\",\"$SECURITY_RULE_ACCESS_CONTROL\",\"$SECURITY_RULE_DIRECTION\",\"$SECURITY_RULE_PROTOCOL\","
    echo -n "\"$(output_source_address_prefix)\","
    echo -n "\"$(output_source_port_ranges)\","
    echo -n "\"$(output_destination_address_prefix)\","
    echo -n "\"$(output_destination_port_ranges)\","
    echo -n "\"$(output_notes)\""
    echo ""  # Newline at the end
}

# Function to output Security Rule firewall rule in text format
function output_security_rule_text() {
    cat <<EOF
Subscription Name: $SUBSCRIPTION_NAME
Resource Group Name: $RESOURCE_GROUP_NAME
Resource Group Location: $RESOURCE_GROUP_LOCATION
Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE
Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE
Resource Group PAR: $RESOURCE_GROUP_PAR
Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID
Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID
Network Security Group Name: $NETWORK_SECURITY_GROUP_NAME
Network Security Group Location: $NETWORK_SECURITY_GROUP_LOCATION
Violation: $SECURITY_RULE_VIOLATION
Open From Internet Violation: $SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION
RDP Violation: $SECURITY_RULE_RDP_VIOLATION
SSH Violation: $SECURITY_RULE_SSH_VIOLATION
SQL Server Violation: $SECURITY_RULE_SQL_SERVER_VIOLATION
HTTP Violation: $SECURITY_RULE_HTTP_VIOLATION
UDP Violation: $SECURITY_RULE_UDP_VIOLATION
Security Rule:
    Name: $SECURITY_RULE_NAME
    Description: $SECURITY_RULE_DESCRIPTION
    Access Control: $SECURITY_RULE_ACCESS_CONTROL
    Direction: $SECURITY_RULE_DIRECTION
    Protocol: $SECURITY_RULE_PROTOCOL
    $(output_source_address_prefix)
    $(output_source_port_ranges)
    $(output_destination_address_prefix)
    $(output_destination_port_ranges)
    $(output_notes)
    $BLANK_LINE
EOF
}

# Function to parse subscription information
function parse_subscription() {
    local l_SUBSCRIPTION=$1
    SUBSCRIPTION_NAME=$(jq -r '.displayName // empty' <<< "$l_SUBSCRIPTION")
}

# Function to parse resource group information
function parse_resource_group() {
    local l_RESOURCE_GROUP=$1;

    # Parse resource group information from JSON
    RESOURCE_GROUP_NAME=$(jq -rc '.name' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_LOCATION=$(jq -rc '.location' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_APPLICATION_CODE=$(jq -rc '.tags.applicationCode // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(jq -rc '.tags.departmentChargeCode // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_PAR=$(jq -rc '.tags.par // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_REQUESTOR_AD_ID=$(jq -rc '.tags.requestorADID // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(jq -rc '.tags.requestorEmployeeID // ""' <<< "$l_RESOURCE_GROUP");
}

# Function to parse Network Security Group information
function parse_network_security_group() {
    local l_NETWORK_SECURITY_GROUP=$1;

    # Parse Network Security Group information from JSON
    NETWORK_SECURITY_GROUP_NAME=$(jq -rc '.name // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_LOCATION=$(jq -rc '.location // empty' <<< "$l_NETWORK_SECURITY_GROUP");
    NETWORK_SECURITY_GROUP_SECURITY_RULES=$(jq -rc '.securityRules // empty' <<< "$l_NETWORK_SECURITY_GROUP");
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
	fi

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

# Include common menu
source ./common-menu.inc;

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS != "[]" ]]; then

	# Debugging information
	if [[ $DEBUG == "True" ]]; then
		echo "Subscriptions (JSON): $SUBSCRIPTIONS";
	fi;

	output_header;
		
	echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION;do

		# Parse subscription information
		parse_subscription "$SUBSCRIPTION";
		
		# Get resource groups for the subscription
		declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME");

		if [[ $DEBUG == "True" && $CSV == "False" ]]; then
			echo "Resources Groups (JSON): $RESOURCE_GROUPS";
		fi;

		# Process each resource group
		if [[ $RESOURCE_GROUPS != "[]" ]]; then

			echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP;do

				# Parse resource group information
				parse_resource_group "$RESOURCE_GROUP";

				# Get Security Rules for the resource group
				declare NETWORK_SECURITY_GROUPS=$(get_network_security_groups "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME");

				# Process each Network Security Group
				if [[ $NETWORK_SECURITY_GROUPS != "[]" ]]; then

					if [[ $DEBUG == "True" && $CSV == "False" ]]; then
						echo "Network Security Groups (JSON): $NETWORK_SECURITY_GROUPS";
					fi;

					echo $NETWORK_SECURITY_GROUPS | jq -rc '.[]' | while IFS='' read NETWORK_SECURITY_GROUP;do
						
						if [[ $DEBUG == "True" && $CSV == "False" ]]; then
							echo "Network Security Group (JSON): $NETWORK_SECURITY_GROUP";
						fi;
						
						# Parse Security Rule information
						parse_network_security_group "$NETWORK_SECURITY_GROUP";

						# Process each Security Rule
						if [[ $NETWORK_SECURITY_GROUP_SECURITY_RULES != "[]" ]]; then

							if [[ $DEBUG == "True" && $CSV == "False" ]]; then
								echo "Security Rules (JSON): $NETWORK_SECURITY_GROUP_SECURITY_RULES";
							fi;

							echo $NETWORK_SECURITY_GROUP_SECURITY_RULES | jq -rc '.[]' | while IFS='' read SECURITY_RULE;do
								
								if [[ $DEBUG == "True" && $CSV == "False" ]]; then
									echo "Security Rule (JSON): $SECURITY_RULE";
								fi;

								# Parse Security Rule information
								parse_security_rule "$SECURITY_RULE";
								output_security_rule;						
							done;
						else
							# Print message if no Security Rules found
							if [[ $CSV == "False" ]]; then
								echo "No Security Rules found";
								echo $BLANK_LINE;
							fi;
						fi;
					done;
				else
					# Print message if no Security Rules found
					if [[ $CSV == "False" ]]; then
						echo "No Network Security Groups found";
						echo $BLANK_LINE;
					fi;
				fi;
			done;
		else
			# Print message if no resource groups found
			if [[ $CSV == "False" ]]; then
				echo "No resource groups found";
				echo $BLANK_LINE;
			fi;
		fi;
	done;
else
	# Print message if no subscriptions found
	if [[ $CSV == "False" ]]; then
		echo "No subscriptions found";
		echo $BLANK_LINE;
	fi;
fi;
