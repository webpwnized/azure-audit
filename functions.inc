#!/bin/bash

function get_subscriptions() {

	local l_SUBSCRIPTION_ID=$1;
	local l_RESULTS="";

	if [[ $l_SUBSCRIPTION_ID == "" ]]; then
		# Get all subscriptions
		l_RESULTS=$(az account subscription list --output="json" 2>/dev/null);
	else
		# User wants to look at a specific subscription
		l_RESULTS=$(az account subscription list --query "[?subscriptionId=='$l_SUBSCRIPTION_ID']" --output="json" 2>/dev/null);
	fi;

	echo $l_RESULTS;
}

function get_resource_groups() {

	local l_SUBSCRIPTION_ID="$1";
	local l_RESOURCE_GROUP_NAME="$2";
	local l_RESULTS="";

	if [[ $l_RESOURCE_GROUP_NAME == "" ]]; then
		# Get all resource groups
		local l_RESULTS=$(az group list --output="json" --subscription="$l_SUBSCRIPTION_ID" 2>/dev/null);
	else
		# User wants to look at a specific resource group
		local l_RESULTS=$(az group list --output="json" --subscription="$l_SUBSCRIPTION_ID" --query "[?name=='$l_RESOURCE_GROUP_NAME']" 2>/dev/null);
	fi;

	echo $l_RESULTS;
}

function get_azure_sql_servers() {

	local l_SUBSCRIPTION_ID=$1;
	local l_RESOURCE_GROUP_NAME=$2;
	local l_RESULTS=$(az sql server list --output="json" --subscription="$l_SUBSCRIPTION_ID" --resource-group="$l_RESOURCE_GROUP_NAME" 2>/dev/null);
	
	echo $l_RESULTS;
}
