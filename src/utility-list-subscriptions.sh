#!/bin/bash

# Debug: ./utility-list-subscriptions.sh --subscription 651b4cdc-83bc-466a-975d-df1a9c2be5b1

# Source common constants and functions
source ./common-constants.inc
source ./common-functions.inc

# Output header based on CSV flag
function output_header() {
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"MEMBERS\""
}

# Output subscription information
function output_subscription() {
    if [[ $SUBSCRIPTION_NAME != "Visual Studio"* ]]; then
        output_subscription_helper
    fi
}

# Determine output format and call appropriate function
function output_subscription_helper() {
    if [[ $CSV == "True" ]]; then
        output_subscription_csv
    else
        output_subscription_text
    fi
}

# Output subscription information in CSV format
function output_subscription_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$MEMBERS\""
}

# Output subscription information in text format
function output_subscription_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Members: $MEMBERS"
    echo $BLANK_LINE
}

# Source common menu
source ./common-menu.inc

# Get subscriptions
declare SUBSCRIPTIONS=$(get_subscriptions "$p_SUBSCRIPTION_ID");
output_debug_info "Subscriptions (JSON): $SUBSCRIPTIONS";

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS == "[]" ]]; then
    output_user_info "No subscriptions found.";
    exit 0
fi

output_header

# Iterate through each subscription
echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
    output_debug_info "Subscription (JSON): $SUBSCRIPTION"
    parse_subscription "$SUBSCRIPTION"

    # Get and process role assignments
    ROLE_ASSIGNMENTS=$(get_subscription_role_assignments "$SUBSCRIPTION_NAME")
    output_debug_info "Role Assignments (JSON): $ROLE_ASSIGNMENTS"
    parse_role_assignments "$ROLE_ASSIGNMENTS"

    output_subscription
done
