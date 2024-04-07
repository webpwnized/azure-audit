#!/bin/bash

# Function to get subscriptions
function get_subscriptions() {
    local l_SUBSCRIPTION_ID=$1;
    local l_RESULTS="";

    if [[ $l_SUBSCRIPTION_ID == "" ]]; then
        # Get all subscriptions if no specific subscription ID provided
        l_RESULTS=$(az account subscription list --output="json" 2>/dev/null);
    else
        # Get specific subscription by ID
        l_RESULTS=$(az account subscription list --query "[?subscriptionId=='$l_SUBSCRIPTION_ID']" --output="json" 2>/dev/null);
    fi;

    echo $l_RESULTS;
}

# Function to get resource groups
function get_resource_groups() {
    local l_SUBSCRIPTION_ID="$1";
    local l_RESOURCE_GROUP_NAME="$2";
    local l_RESULTS="";

    if [[ $l_RESOURCE_GROUP_NAME == "" ]]; then
        # Get all resource groups if no specific resource group name provided
        local l_RESULTS=$(az group list --output="json" --subscription="$l_SUBSCRIPTION_ID" 2>/dev/null);
    else
        # Get specific resource group by name
        local l_RESULTS=$(az group list --output="json" --subscription="$l_SUBSCRIPTION_ID" --query "[?name=='$l_RESOURCE_GROUP_NAME']" 2>/dev/null);
    fi;

    echo $l_RESULTS;
}

# Function to get Azure SQL servers
function get_azure_sql_servers() {
    local l_SUBSCRIPTION_ID=$1;
    local l_RESOURCE_GROUP_NAME=$2;
    
    # Get Azure SQL servers
    az sql server list \
        --output="json" \
        --subscription="$l_SUBSCRIPTION_ID" \
        --resource-group="$l_RESOURCE_GROUP_NAME" 2>/dev/null;
}

# Function to get Azure SQL server firewall rules
function get_azure_sql_server_firewall_rules() {
    local l_SUBSCRIPTION_ID=$1;
    local l_RESOURCE_GROUP_NAME=$2;
    local l_SQL_SERVER_NAME=$3;
    
    # Get Azure SQL server firewall rules
    az sql server firewall-rule list \
        --subscription="$l_SUBSCRIPTION_ID" \
        --resource-group="$l_RESOURCE_GROUP_NAME" \
        --server="$l_SQL_SERVER_NAME" \
        --output="json" 2>/dev/null;
}

# Function to get role assignments for a subscription
function get_subscription_role_assignments() {
    local l_SUBSCRIPTION_NAME="$1";
    # Get subscription role assignments
    az role assignment list --subscription "$l_SUBSCRIPTION_NAME" --output="json" 2>/dev/null;
}

# Function to get members of a group
function get_group_members() {
    local l_GROUP_NAME="$1";
    # Get group members
    az ad group member list --group "$GROUP_NAME" --output="json";
}

# Function to get members of a group
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
