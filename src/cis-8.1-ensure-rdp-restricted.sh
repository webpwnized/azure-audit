#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql
# reference: 8.1 Ensure that RDP access from the Internet is restricted (Automated) - Networking Serivces - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0.pdf
# note: this script also checks SSH(8.2), UDP(8.3), HTTP/HTTPS(8.4), & many more

# Debug: ./cis-8.1-ensure-rdp-restricted.sh -s 1014e3e6-e0cf-44c0-8efe-ba17d0c6e3ed -r rg-scd-prd

# Include common constants and functions
source ./includes/common-constants.inc;
source ./includes/common-functions.inc;

# Function to output header based on CSV flag
function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header
	fi
}

# Function to output Security Rule firewall rule
function output_security_rule() {
	if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        if [[ $CSV == "True" ]]; then
            output_security_rule_csv;
        else
            output_security_rule_text;
        fi
    fi
}

# Function to output Source Address Prefix
function output_source_address_prefix() {
    if [[ -n "$SECURITY_RULE_SOURCE_ADDRESS_PREFIXES" ]]; then
        echo "$SECURITY_RULE_SOURCE_ADDRESS_PREFIXES"
    else
        echo "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX"
    fi
}

# Function to output Source Port Ranges
function output_source_port_ranges() {
    if [[ -n "$SECURITY_RULE_SOURCE_PORT_RANGES" ]]; then
        echo "$SECURITY_RULE_SOURCE_PORT_RANGES"
    else
        echo "$SECURITY_RULE_SOURCE_PORT_RANGE"
    fi
}

# Function to output Destination Address Prefix
function output_destination_address_prefix() {
    if [[ -n "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIXES" ]]; then
        echo "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIXES"
    else
        echo "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX"
    fi
}

# Function to output Destination Port Ranges
function output_destination_port_ranges() {
    if [[ -n "$SECURITY_RULE_DESTINATION_PORT_RANGES" ]]; then
        echo "$SECURITY_RULE_DESTINATION_PORT_RANGES"
    else
        echo "$SECURITY_RULE_DESTINATION_PORT_RANGE"
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

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureTrafficManager" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureTrafficManager" ]]; then
        echo "Note: AzureTrafficManager means that traffic is allowed from Azure Traffic Manager."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzurePlatformDNS" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzurePlatformDNS" ]]; then
        echo "Note: AzurePlatformDNS means that traffic is allowed from Azure platform DNS services."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureCloudServices" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureCloudServices" ]]; then
        echo "Note: AzureCloudServices means that traffic is allowed from Azure Cloud Services."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureActiveDirectory" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureActiveDirectory" ]]; then
        echo "Note: AzureActiveDirectory means that traffic is allowed from Azure Active Directory services."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureAppService" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureAppService" ]]; then
        echo "Note: AzureAppService means that traffic is allowed from Azure App Services."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "GatewayManager" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "GatewayManager" ]]; then
        echo "Note: GatewayManager means that traffic is allowed from Azure VPN Gateway Manager."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "StorageAccount" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "StorageAccount" ]]; then
        echo "Note: StorageAccount means that traffic is allowed from or to Azure Storage Accounts."
    fi

    if [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "AzureKubernetesService" || "$SECURITY_RULE_DESTINATION_ADDRESS_PREFIX" == "AzureKubernetesService" ]]; then
        echo "Note: AzureKubernetesService means that traffic is allowed from Azure Kubernetes Service (AKS)."
    fi
}

# Function to output CSV header
function output_csv_header() {
                cat <<EOF
"SUBSCRIPTION_NAME","RESOURCE_GROUP_NAME","RESOURCE_GROUP_LOCATION","RESOURCE_GROUP_APPLICATION_CODE","RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE","RESOURCE_GROUP_PAR","RESOURCE_GROUP_REQUESTOR_AD_ID","RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID","NETWORK_SECURITY_GROUP_NAME","NETWORK_SECURITY_GROUP_LOCATION","VIOLATION","OPEN_FROM_INTERNET_VIOLATION","OPEN_FROM_EXTERNAL_NETWORK_VIOLATION","RDP_VIOLATION","SSH_VIOLATION","DATABASE_VIOLATION","HTTP_VIOLATION","FTP_VIOLATION","EMAIL_VIOLATION","UDP_VIOLATION","ALL_SOURCE_PORTS_ALLOWED_VIOLATION","ALL_DESTINATION_PORTS_ALLOWED_VIOLATION","SECURITY_RULE_NAME","SECURITY_RULE_DESCRIPTION","SECURITY_RULE_ACCESS_CONTROL","SECURITY_RULE_DIRECTION","SECURITY_RULE_PROTOCOL","SOURCE_ADDRESS_PREFIX","SOURCE_PORT_RANGES","DESTINATION_ADDRESS_PREFIX","DESTINATION_PORT_RANGES","NOTES"
EOF
}

# Function to output Security Rule firewall rule in CSV format
function output_security_rule_csv() {
    echo -n "\"$SUBSCRIPTION_NAME\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_LOCATION\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$NETWORK_SECURITY_GROUP_NAME\",\"$NETWORK_SECURITY_GROUP_LOCATION\",\"$SECURITY_RULE_VIOLATION\",\"$SECURITY_RULE_OPEN_FROM_INTERNET_VIOLATION\",\"$SECURITY_RULE_OPEN_FROM_EXTERNAL_NETWORK_VIOLATION\",\"$SECURITY_RULE_RDP_VIOLATION\",\"$SECURITY_RULE_SSH_VIOLATION\",\"$SECURITY_RULE_DATABASE_VIOLATION\",\"$SECURITY_RULE_HTTP_VIOLATION\",\"$SECURITY_RULE_FTP_VIOLATION\",\"$SECURITY_RULE_EMAIL_VIOLATION\",\"$SECURITY_RULE_UDP_VIOLATION\",\"$SECURITY_RULE_ALL_SOURCE_PORTS_ALLOWED_VIOLATION\",\"$SECURITY_RULE_ALL_DESTINATION_PORTS_ALLOWED_VIOLATION\",\"$SECURITY_RULE_NAME\",\"$SECURITY_RULE_DESCRIPTION\",\"$SECURITY_RULE_ACCESS_CONTROL\",\"$SECURITY_RULE_DIRECTION\",\"$SECURITY_RULE_PROTOCOL\","
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
Subscription ID: $SUBSCRIPTION_ID
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
Open From External Network Violation: $SECURITY_RULE_OPEN_FROM_EXTERNAL_NETWORK_VIOLATION
RDP Violation: $SECURITY_RULE_RDP_VIOLATION
SSH Violation: $SECURITY_RULE_SSH_VIOLATION
Database Violation: $SECURITY_RULE_DATABASE_VIOLATION
HTTP Violation: $SECURITY_RULE_HTTP_VIOLATION
FTP Violation: $SECURITY_RULE_FTP_VIOLATION
Email Violation: $SECURITY_RULE_EMAIL_VIOLATION
UDP Violation: $SECURITY_RULE_UDP_VIOLATION
All Source Ports Allowed Violation: $SECURITY_RULE_ALL_SOURCE_PORTS_ALLOWED_VIOLATION
All Destination Ports Allowed Violation: $SECURITY_RULE_ALL_DESTINATION_PORTS_ALLOWED_VIOLATION
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

# Include common menu
source ./includes/common-menu.inc;

# Get subscriptions
SUBSCRIPTIONS="$(get_subscriptions "$p_SUBSCRIPTION_ID")"
output_debug_info "" "" "Subscriptions" "$SUBSCRIPTIONS";

check_if_subscriptions_exists "$SUBSCRIPTIONS"

output_header;

# Process each subscription
echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
    
    output_debug_info "" "" "Subscription" "$SUBSCRIPTION";

    # Parse subscription information
    parse_subscription "$SUBSCRIPTION"

    # Skip Visual Studio subscriptions
    if [[ "$SUBSCRIPTION_NAME" == "Visual Studio"* ]]; then
        continue
    fi

    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME");
    output_debug_info "" "" "Resources Groups" "$RESOURCE_GROUPS";

    # Process each resource group
    if [[ $RESOURCE_GROUPS == "[]" ]]; then
        # Print message if no resource groups found
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME";
        continue
    fi

    echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do
        output_debug_info "" "" "Resources Group" "$RESOURCE_GROUP";

        # Parse resource group information
        parse_resource_group "$RESOURCE_GROUP";

        # Get Security Rules for the resource group
        declare NETWORK_SECURITY_GROUPS=$(get_network_security_groups "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME");
        output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Network Security Groups" "$NETWORK_SECURITY_GROUPS"

        # Process each Network Security Group
        if [[ $NETWORK_SECURITY_GROUPS == "[]" ]]; then
            output_user_info "No Network Security Groups found for resource group $RESOURCE_GROUP_NAME";
            continue
        fi
        
        echo $NETWORK_SECURITY_GROUPS | jq -rc '.[]' | while IFS='' read NETWORK_SECURITY_GROUP; do
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Network Security Group" "$NETWORK_SECURITY_GROUP";

            # Parse Security Rule information
            parse_network_security_group "$NETWORK_SECURITY_GROUP";

            # Process each Security Rule
            if [[ $NETWORK_SECURITY_GROUP_SECURITY_RULES == "[]" ]]; then
                output_user_info "No Security Rules found for Network Security Group $NETWORK_SECURITY_GROUP_NAME";
                continue
            fi

            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Security Rules" "$NETWORK_SECURITY_GROUP_SECURITY_RULES"

            echo $NETWORK_SECURITY_GROUP_SECURITY_RULES | jq -rc '.[]' | while IFS='' read SECURITY_RULE; do
                output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Security Rule" "$SECURITY_RULE";

                # Parse Security Rule information
                parse_security_rule "$SECURITY_RULE";
                output_security_rule;
            done;
        done;
    done;
done;
