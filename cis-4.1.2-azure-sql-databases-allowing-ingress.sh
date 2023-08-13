#!/bin/bash

source ./common-constants.inc;
source ./functions.inc;

function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header;
	fi;
};

function output_csv_header() {
	echo "\"SUBSCRIPTION_NAME\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"SQL_SERVER_NAME\",\"SQL_SERVER_DOMAIN_NAME\",\"SQL_SERVER_TYPE\",\"SQL_SERVER_TAGS\",\"SQL_SERVER_PUBLIC_NETWORK_ACCESS\",\"SQL_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"SQL_SERVER_ADMIN_LOGIN\",\"SQL_SERVER_ADMIN_LOGIN_PASSWORD\",\"SQL_SERVER_ADMINS\",\"SQL_SERVER_TLS_VERSION\",\"SQL_SERVER_LOCATION\",\"SQL_SERVER_VERSION\",\"SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\"";
};

function output_sql_server() {
	if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
		output_sql_server_helper;
	fi;
};

function output_sql_server_helper() {
	if [[ $CSV == "True" ]]; then
		output_sql_server_csv;
	else
		output_sql_server_text;
	fi;
};

function output_sql_server_csv() {
	echo "\"$SUBSCRIPTION_NAME\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$SQL_SERVER_NAME\",\"$SQL_SERVER_DOMAIN_NAME\",\"$SQL_SERVER_TYPE\",\"$SQL_SERVER_TAGS\",\"$SQL_SERVER_PUBLIC_NETWORK_ACCESS\",\"$SQL_SERVER_RESTRICT_OUTBOUND_ACCESS\",\"$SQL_SERVER_ADMIN_LOGIN\",\"$SQL_SERVER_ADMIN_LOGIN_PASSWORD\",\"$SQL_SERVER_ADMINS\",\"$SQL_SERVER_TLS_VERSION\",\"$SQL_SERVER_LOCATION\",\"$SQL_SERVER_VERSION\",\"$SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG\",\"$SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG\"";
};

function output_sql_server_text() {
	echo "Subscription Name: $SUBSCRIPTION_NAME";
	echo "Resource Group Name: $RESOURCE_GROUP_NAME";
	echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE";
	echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE";
	echo "Resource Group PAR: $RESOURCE_GROUP_PAR";
	echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID";
	echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID";
	echo "SQL Server Name: $SQL_SERVER_NAME";
	echo "SQL Server Domain Name: $SQL_SERVER_DOMAIN_NAME";
	echo "SQL Server Type: $SQL_SERVER_TYPE";
	echo "SQL Server Tags: $SQL_SERVER_TAGS";
	echo "SQL Server allows public network access: $SQL_SERVER_PUBLIC_NETWORK_ACCESS";
	echo "SQL Server allow outbound access: $SQL_SERVER_RESTRICT_OUTBOUND_ACCESS";
	echo "SQL Server Login: $SQL_SERVER_ADMIN_LOGIN";
	echo "SQL Server Password: $SQL_SERVER_ADMIN_LOGIN_PASSWORD";
	echo "SQL Server Admins: $SQL_SERVER_ADMINS";
	echo "SQL Server TLS Version: $SQL_SERVER_TLS_VERSION";
	echo "SQL Server Location: $SQL_SERVER_LOCATION";
	echo "SQL Server Version: $SQL_SERVER_VERSION";
	echo $BLANK_LINE;
};

function parse_subscription() {
	local l_SUBSCRIPTION=$1;
	SUBSCRIPTION_NAME=$(echo $l_SUBSCRIPTION | jq -rc '.displayName');
};

function parse_resource_group() {
	local l_RESOURCE_GROUP=$1;

	RESOURCE_GROUP_NAME=$(echo $l_RESOURCE_GROUP | jq -rc '.name');
	RESOURCE_GROUP_APPLICATION_CODE=$(echo $l_RESOURCE_GROUP | jq -rc '.tags.applicationCode');
	RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(echo $l_RESOURCE_GROUP | jq -rc '.tags.departmentChargeCode');
	RESOURCE_GROUP_PAR=$(echo $l_RESOURCE_GROUP | jq -rc '.tags.par');
	RESOURCE_GROUP_REQUESTOR_AD_ID=$(echo $l_RESOURCE_GROUP | jq -rc '.tags.requestorAdId');
	RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(echo $l_RESOURCE_GROUP | jq -rc '.tags.requestorEmployeeId');
};

function parse_sql_server() {
	local l_SQL_SERVER=$1;
	
	SQL_SERVER_ADMIN_LOGIN=$(echo $SQL_SERVER | jq -rc '.administratorLogin');
	SQL_SERVER_ADMIN_LOGIN_PASSWORD=$(echo $SQL_SERVER | jq -rc '.administratorLoginPassword');
	SQL_SERVER_ADMINS=$(echo $SQL_SERVER | jq -rc '.administrators');
	SQL_SERVER_DOMAIN_NAME=$(echo $SQL_SERVER | jq -rc '.fullyQualifiedDomainName');
	SQL_SERVER_LOCATION=$(echo $SQL_SERVER | jq -rc '.location');
	SQL_SERVER_TLS_VERSION=$(echo $SQL_SERVER | jq -rc '.minimalTlsVersion');
	SQL_SERVER_NAME=$(echo $SQL_SERVER | jq -rc '.name');
	SQL_SERVER_PUBLIC_NETWORK_ACCESS=$(echo $SQL_SERVER | jq -rc '.publicNetworkAccess');
	SQL_SERVER_RESTRICT_OUTBOUND_ACCESS=$(echo $SQL_SERVER | jq -rc '.restrictOutboundNetworkAccess');
	SQL_SERVER_TAGS=$(echo $SQL_SERVER | jq -rc '.tags');
	SQL_SERVER_TYPE=$(echo $SQL_SERVER | jq -rc '.type');
	SQL_SERVER_VERSION=$(echo $SQL_SERVER | jq -rc '.version');

	SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="False";
	if [[ $SQL_SERVER_PUBLIC_NETWORK_ACCESS == "Enabled" ]]; then
		SQL_SERVER_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG="True";
	fi;

	SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG="False";
	if [[ $SQL_SERVER_RESTRICT_OUTBOUND_ACCESS == "Enabled" ]]; then
		SQL_SERVER_OUTBOUND_NETWORK_ACCESS_VIOLATION_FLAG="True";
	fi;
};

source ./common-menu.inc;

declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");

if [[ $DEBUG == "True" ]]; then
	echo "Subscriptions (JSON): $SUBSCRIPTIONS";
fi;

if [[ $SUBSCRIPTIONS != "[]" ]]; then

	output_header;
		
	echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION;do

		parse_subscription "$SUBSCRIPTION";
		
		declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME");

		if [[ $DEBUG == "True" && $CSV == "False" ]]; then
			echo "Resources Groups (JSON): $RESOURCE_GROUPS";
		fi;

		if [[ $RESOURCE_GROUPS != "[]" ]]; then

			echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP;do

				parse_resource_group "$RESOURCE_GROUP";

				declare SQL_SERVERS=$(get_azure_sql_servers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME");

				# Debug: ./cis-4.1.2-azure-sql-databases-allowing-ingress.sh --subscription b09bcb9d-e055-4950-a9dd-2ab6002ef86c --resource-group rg-scd-dev

				if [[ $DEBUG == "True" && $CSV == "False" ]]; then
					echo "SQL Servers (JSON): $SQL_SERVERS";
				fi;

				if [[ $SQL_SERVERS != "[]" ]]; then

					echo $SQL_SERVERS | jq -rc '.[]' | while IFS='' read SQL_SERVER;do
						parse_sql_server "$SQL_SERVER";
						declare SQL_SERVER_FIREWALL_RULES=$(get_azure_sql_server_firewall_rules "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$SQL_SERVER_NAME");
						echo "$SQL_SERVER_FIREWALL_RULES";
						output_sql_server;
					done;

				else
					if [[ $CSV == "False" ]]; then
						echo "No SQL servers found";
						echo $BLANK_LINE;
					fi;
				fi;

			done;
		else
			if [[ $CSV == "False" ]]; then
				echo "No resource groups found";
				echo $BLANK_LINE;
			fi;
		fi;
	done;
else
	if [[ $CSV == "False" ]]; then
		echo "No subscriptions found";
		echo $BLANK_LINE;
	fi;
fi;

