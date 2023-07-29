#!/bin/bash

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

declare BLANK_LINE="";
declare DEBUG="False";
declare CSV="False";
declare HELP=$(cat << EOL
	$0 [-c, --csv] [-d, --debug] [-h, --help]	
EOL
);

for arg in "$@"; do
  shift
  case "$arg" in
    "--help") 			set -- "$@" "-h" ;;
    "--debug") 			set -- "$@" "-d" ;;
    "--csv") 			set -- "$@" "-c" ;;
    *)        			set -- "$@" "$arg"
  esac
done

while getopts "hdc" option
do 
    case "${option}" in
        d)
        	DEBUG="True";;
        c)
        	CSV="True";;
        h)
        	echo $HELP; 
        	exit 0;;
    esac;
done;

declare RESULTS=$(az account subscription list --output="json" 2>/dev/null);

if [[ $DEBUG == "True" ]]; then
	echo "Subscriptions (JSON): $RESULTS";
fi;

if [[ $RESULTS != "[]" ]]; then

	output_header;
		
	echo $RESULTS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION;do

		SUBSCRIPTION_NAME=$(echo $SUBSCRIPTION | jq -rc '.displayName');
		SUBSCRIPTION_STATE=$(echo $SUBSCRIPTION | jq -rc '.state');
		SUBSCRIPTION_ID=$(echo $SUBSCRIPTION | jq -rc '.subscriptionId');
		
		output_subscription;
	done;
else
	echo "No subscriptions found";
	echo $BLANK_LINE;
fi;

