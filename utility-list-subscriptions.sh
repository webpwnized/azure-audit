#!/bin/bash

source ./common-constants.inc;
source ./functions.inc;

function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header;
	fi;
};

function output_csv_header() {
	echo "\"SUBSCRIPTION_NAME\", \"SUBSCRIPTION_STATE\", \"SUBSCRIPTION_ID\"";
};

function output_subscription() {
	if [[ $SUBSCRIPTION_NAME != "Visual Studio"* ]]; then
		output_subscription_helper;
	fi;
};

function output_subscription_helper() {
	if [[ $CSV == "True" ]]; then
		output_subscription_csv;
	else
		output_subscription_text;
	fi;
};

function output_subscription_csv() {
	echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\"";
};

function output_subscription_text() {
	echo "Subscription Name: $SUBSCRIPTION_NAME";
	echo "Subscription State: $SUBSCRIPTION_STATE";
	echo "Subscription ID: $SUBSCRIPTION_ID";
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
		
		output_subscription;
	done;
else
	echo "No subscriptions found";
	echo $BLANK_LINE;
fi;

