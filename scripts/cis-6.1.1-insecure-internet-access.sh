#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql

# Debug: ./cis-4.1.2-azure-sql-databases-allowing-ingress.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

# Include common constants and functions
source ./common-constants.inc;
source ./functions.inc;

# Function to output header based on CSV flag
function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header
	fi
}

# Function to output CSV header
function output_csv_header() {
	echo "\"SUBSCRIPTION_NAME\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"SECURITY_RULE_NAME\",\"SECURITY_RULE_DOMAIN_NAME\",\"SECURITY_RULE_TYPE\",\"SECURITY_RULE_ENVIRONMENT\",\"SECURITY_RULE_APPLICATION_CODE\",\"SECURITY_RULE_APPLICATION_NAME\",\"SECURITY_RULE_REQUESTOR_AD_ID\",\"SECURITY_RULE_REQUESTOR_EMPLOYEE_ID\",\"SECURITY_RULE_PUBLIC_NETWORK_ACCESS\",\"SECURITY_RULE_RESTRICT_OUTBOUND_ACCESS\",\"SECURITY_RULE_ADMIN_LOGIN\",\"SECURITY_RULE_ADMIN_TYPE\",\"SECURITY_RULE_ADMIN_PRINCIPLE_TYPE\",\"SECURITY_RULE_ADMIN_PRINCIPLE_LOGIN\",\"SECURITY_RULE_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"SECURITY_RULE_TLS_VERSION\",\"SECURITY_RULE_LOCATION\",\"SECURITY_RULE_VERSION\",\"SECURITY_RULE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"SECURITY_RULE_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"FIREWALL_RULE_NAME\",\"FIREWALL_RULE_START_IP_ADDRESS\",\"FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\"";
};

# Function to output Security Rule firewall rule in CSV format
function output_SECURITY_RULE_firewall_rule_csv() {
	echo "\"$SUBSCRIPTION_NAME\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$SECURITY_RULE_NAME\",\"$SECURITY_RULE_DOMAIN_NAME\",\"$SECURITY_RULE_TYPE\",\"$SECURITY_RULE_ENVIRONMENT\",\"$SECURITY_RULE_APPLICATION_CODE\",\"$SECURITY_RULE_APPLICATION_NAME\",\"$SECURITY_RULE_REQUESTOR_AD_ID\",\"$SECURITY_RULE_REQUESTOR_EMPLOYEE_ID\",\"$SECURITY_RULE_PUBLIC_NETWORK_ACCESS\",\"$SECURITY_RULE_RESTRICT_OUTBOUND_ACCESS\",\"$SECURITY_RULE_ADMIN_LOGIN\",\"$SECURITY_RULE_ADMIN_TYPE\",\"$SECURITY_RULE_ADMIN_PRINCIPLE_TYPE\",\"$SECURITY_RULE_ADMIN_PRINCIPLE_LOGIN\",\"$SECURITY_RULE_ADMIN_AZURE_LOGIN_ENABLED_FLAG\",\"$SECURITY_RULE_TLS_VERSION\",\"$SECURITY_RULE_LOCATION\",\"$SECURITY_RULE_VERSION\",\"$SECURITY_RULE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$SECURITY_RULE_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\",\"$FIREWALL_RULE_NAME\",\"$FIREWALL_RULE_START_IP_ADDRESS\",\"$FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG\",\"$FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG\"";
};

# Function to output Security Rule firewall rule
function output_SECURITY_RULE_firewall_rule() {
	if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
		output_SECURITY_RULE_firewall_rule_helper;
	fi;
};

# Helper function to output Security Rule firewall rule
function output_SECURITY_RULE_firewall_rule_helper() {
	if [[ $CSV == "True" ]]; then
		output_SECURITY_RULE_firewall_rule_csv;
	else
		output_SECURITY_RULE_firewall_rule_text;
	fi;
};

# Function to output Security Rule firewall rule in text format
function output_SECURITY_RULE_firewall_rule_text() {
	echo "Subscription Name: $SUBSCRIPTION_NAME";
	echo "Resource Group Name: $RESOURCE_GROUP_NAME";
	echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE";
	echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE";
	echo "Resource Group PAR: $RESOURCE_GROUP_PAR";
	echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID";
	echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID";
	echo "Security Rule Name: $SECURITY_RULE_NAME";
	echo "Security Rule Environment: $SECURITY_RULE_ENVIRONMENT";
	echo "Security Rule Application Code: $SECURITY_RULE_APPLICATION_CODE";
	echo "Security Rule Application Name: $SECURITY_RULE_APPLICATION_NAME";
	echo "Security Rule Requestor AD ID: $SECURITY_RULE_REQUESTOR_AD_ID";
	echo "Security Rule Employee ID: $SECURITY_RULE_REQUESTOR_EMPLOYEE_ID";
	echo "Security Rule Domain Name: $SECURITY_RULE_DOMAIN_NAME";
	echo "Security Rule Type: $SECURITY_RULE_TYPE";
	echo "Security Rule Allows Public Network Access: $SECURITY_RULE_PUBLIC_NETWORK_ACCESS";
	echo "Security Rule Allow Outbound Access: $SECURITY_RULE_RESTRICT_OUTBOUND_ACCESS";
	echo "Security Rule Login: $SECURITY_RULE_ADMIN_LOGIN";
	echo "Security Rule Admin Type: $SECURITY_RULE_ADMIN_TYPE";
	echo "Security Rule Admin Principle Type: $SECURITY_RULE_ADMIN_PRINCIPLE_TYPE";
	echo "Security Rule Admin Principle Login: $SECURITY_RULE_ADMIN_PRINCIPLE_LOGIN";
	echo "Security Rule Admin Requires Azure Login: $SECURITY_RULE_ADMIN_AZURE_LOGIN_ENABLED_FLAG";
	echo "Security Rule TLS Version: $SECURITY_RULE_TLS_VERSION";
	echo "Security Rule Location: $SECURITY_RULE_LOCATION";
	echo "Security Rule Version: $SECURITY_RULE_VERSION";
	echo "Firewall Rule Name: $FIREWALL_RULE_NAME";
	echo "Firewall Rule Start IP Address: $FIREWALL_RULE_START_IP_ADDRESS";
	echo "Firewall Rule End IP Address: $FIREWALL_RULE_END_IP_ADDRESS";
	echo "Firewall Rule Resource Group: $FIREWALL_RULE_RESOURCE_GROUP";
	echo $BLANK_LINE;
};

# Function to parse subscription information
function parse_subscription() {
	local l_SUBSCRIPTION=$1;
	SUBSCRIPTION_NAME=$(echo $l_SUBSCRIPTION | jq -rc '.displayName');
};

# Function to parse resource group information
function parse_resource_group() {
    local l_RESOURCE_GROUP=$1;

    # Parse resource group information from JSON
    RESOURCE_GROUP_NAME=$(jq -rc '.name' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_APPLICATION_CODE=$(jq -rc '.tags.applicationCode // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(jq -rc '.tags.departmentChargeCode // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_PAR=$(jq -rc '.tags.par // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_REQUESTOR_AD_ID=$(jq -rc '.tags.requestorAdId // ""' <<< "$l_RESOURCE_GROUP");
    RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(jq -rc '.tags.requestorEmployeeId // ""' <<< "$l_RESOURCE_GROUP");
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
    SECURITY_RULE_NAME=$(jq -r '.name' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_ACCESS_CONTROL=$(jq -r '.access' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_APPLICATION_CODE=$(jq -r '.destinationAddressPrefix' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_APPLICATION_NAME=$(jq -r '.destinationAddressPrefixes' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_REQUESTOR_AD_ID=$(jq -r '.destinationPortRange' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_REQUESTOR_EMPLOYEE_ID=$(jq -r '.destinationPortRanges' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_ADMIN_LOGIN=$(jq -r '.direction' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_ADMIN_TYPE=$(jq -r '.name' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_ADMIN_PRINCIPLE_TYPE=$(jq -r '.protocol' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_ADMIN_PRINCIPLE_LOGIN=$(jq -r '.resourceGroup' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_ADMIN_AZURE_LOGIN_ENABLED_FLAG=$(jq -r '.sourceAddressPrefix' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_DOMAIN_NAME=$(jq -r '.sourceAddressPrefixes' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_LOCATION=$(jq -r '.sourcePortRange' <<< "$l_SECURITY_RULE");
    SECURITY_RULE_TLS_VERSION=$(jq -r '.sourcePortRanges' <<< "$l_SECURITY_RULE");

    # Determine flags for public network access and outbound access violation
    SECURITY_RULE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False";
    if [[ $SECURITY_RULE_PUBLIC_NETWORK_ACCESS == "Enabled" ]]; then
        SECURITY_RULE_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True";
    fi;
}

# Function to parse SQL server firewall rule information
function parse_sql_server_firewall_rule() {
    local l_FIREWALL_RULE=$1

    # Parse SQL server firewall rule information from JSON
    FIREWALL_RULE_NAME=$(jq -rc '.name' <<< "$l_FIREWALL_RULE")
    FIREWALL_RULE_START_IP_ADDRESS=$(jq -rc '.startIpAddress' <<< "$l_FIREWALL_RULE")
    FIREWALL_RULE_END_IP_ADDRESS=$(jq -rc '.endIpAddress' <<< "$l_FIREWALL_RULE")
    FIREWALL_RULE_RESOURCE_GROUP=$(jq -rc '.resourceGroup' <<< "$l_FIREWALL_RULE")

    # Determine flags for firewall rule violation
    FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="False"
    [[ $FIREWALL_RULE_NAME == "AllowAllWindowsAzureIps" ]] && FIREWALL_RULE_ALLOW_ALL_WINDOWS_IP_FLAG="True"

    FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="False"
    if ! [[ $FIREWALL_RULE_START_IP_ADDRESS =~ ^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|127\.) ]]; then
        FIREWALL_RULE_ALLOW_PUBLIC_INGRESS_FLAG="True"
    fi
}

# Include common menu
source ./common-menu.inc;

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");

# Debugging information
if [[ $DEBUG == "True" ]]; then
	echo "Subscriptions (JSON): $SUBSCRIPTIONS";
fi;

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS != "[]" ]]; then
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

    echo $NETWORK_SECURITY_GROUP_NAME
	echo $NETWORK_SECURITY_GROUP_LOCATION
	echo $NETWORK_SECURITY_GROUP_SECURITY_RULES
	exit 1;
						# Process each Security Rule
						if [[ $SECURITY_RULES != "[]" ]]; then
							if [[ $DEBUG == "True" && $CSV == "False" ]]; then
								echo "Security Rules (JSON): $SECURITY_RULES";
							fi;

							echo $SECURITY_RULES | jq -rc '.[].[]' | while IFS='' read SECURITY_RULE;do
								# Parse Security Rule information
								parse_security_rule "$SECURITY_RULE";

								# Get firewall rules for the Security Rule
								declare SECURITY_RULE_FIREWALL_RULES=$(get_azure_SECURITY_RULE_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$SECURITY_RULE_NAME");

								if [[ $SECURITY_RULE_FIREWALL_RULES != "[]" ]]; then
									echo $SECURITY_RULE_FIREWALL_RULES | jq -rc '.[]' | while IFS='' read FIREWALL_RULE;do
										# Parse firewall rule information
										parse_security_rule_firewall_rule "$FIREWALL_RULE";

										# Output Security Rule firewall rule if it does not violate conditions
										if [[ ! $FIREWALL_RULE_NAME =~ ^ClientIPAddress ]]; then
											output_SECURITY_RULE_firewall_rule;
										fi;
									done;
								else
									# Print message if no firewall rules found
									if [[ $CSV == "False" ]]; then
										echo "No Security Rule firewall rules found";
										echo $BLANK_LINE;
									fi;
								fi;
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
