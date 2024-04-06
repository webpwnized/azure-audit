#!/bin/bash

source ./common-constants.inc;
source ./functions.inc;

function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header;
	fi;
};

function output_csv_header() {
	echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_LOCATION\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\"";
};

function output_resource_group() {
	if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
		output_resource_group_helper;
	fi;
};

function output_resource_group_helper() {
	if [[ $CSV == "True" ]]; then
		output_resource_group_csv;
	else
		output_resource_group_text;
	fi;
};

function output_resource_group_csv() {
	echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_LOCATION\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\"";
};

function output_resource_group_text() {
	echo "Subscription Name: $SUBSCRIPTION_NAME";
	echo "Subscription State: $SUBSCRIPTION_STATE";
	echo "Subscription ID: $SUBSCRIPTION_ID";
	echo "Resource Group Name: $RESOURCE_GROUP_NAME";
	echo "Resource Group Location: $RESOURCE_GROUP_LOCATION";
	echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE";
	echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE";
	echo "Resource Group PAR: $RESOURCE_GROUP_PAR";
	echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID";
	echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID";
	echo $BLANK_LINE;
};

source ./common-menu.inc;

declare SUBSCRIPTIONS=$(get_subscriptions $p_SUBSCRIPTION_ID);

if [[ $DEBUG == "True" ]]; then
	echo "Subscriptions (JSON): $SUBSCRIPTIONS";
fi;

if [[ $SUBSCRIPTIONS != "[]" ]]; then

	output_header;
		
	echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION;do

		SUBSCRIPTION_NAME=$(echo $SUBSCRIPTION | jq -rc '.displayName');
		SUBSCRIPTION_STATE=$(echo $SUBSCRIPTION | jq -rc '.state');
		SUBSCRIPTION_ID=$(echo $SUBSCRIPTION | jq -rc '.subscriptionId');
		
		declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME);

		if [[ $DEBUG == "True" ]]; then
			echo "Resources Groups (JSON): $RESOURCE_GROUPS";
		fi;

		if [[ $RESOURCE_GROUPS != "[]" ]]; then
				
			echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP;do

				RESOURCE_GROUP_NAME=$(echo $RESOURCE_GROUP | jq -rc '.name');
				RESOURCE_GROUP_LOCATION=$(echo $RESOURCE_GROUP | jq -rc '.location');
				RESOURCE_GROUP_APPLICATION_CODE=$(echo $RESOURCE_GROUP | jq -rc '.tags.applicationCode');
				RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(echo $RESOURCE_GROUP | jq -rc '.tags.departmentChargeCode');
				RESOURCE_GROUP_PAR=$(echo $RESOURCE_GROUP | jq -rc '.tags.par');
				RESOURCE_GROUP_REQUESTOR_AD_ID=$(echo $RESOURCE_GROUP | jq -rc '.tags.requestorAdId');
				RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(echo $RESOURCE_GROUP | jq -rc '.tags.requestorEmployeeId');
				
				output_resource_group;
			done;
		else
			echo "No resource groups found";
			echo $BLANK_LINE;
		fi;
	done;
else
	echo "No subscriptions found";
	echo $BLANK_LINE;
fi;

