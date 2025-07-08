#!/bin/bash

# Reference: 3.1 Ensure that 'Firewalls & Networks' is limited to use selected networks instead of all networks (Automated) - CIS_Microsoft_Azure_Database_Services_Benchmark_v1.0.0

# Debug: ./cis-3.1-ensure-firewalls-networks-limited-instead-all-networks.sh -s SUBSCRIPTION_ID -r RESOURCE_NAME --debug

# Include common constants and functions
source ./includes/common-constants.inc;
source ./includes/common-functions.inc;

# Function to output header based on CSV flag
function output_header() {
	if [[ $CSV == "True" ]]; then
		output_csv_header
	fi
}

# Output CSV header
function output_csv_header() {
    echo "SUBSCRIPTION_NAME,SUBSCRIPTION_STATE,SUBSCRIPTION_ID,RESOURCE_GROUP_NAME,RESOURCE_GROUP_LOCATION,RESOURCE_GROUP_APPLICATION_CODE,RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE,RESOURCE_GROUP_PAR,RESOURCE_GROUP_REQUESTOR_AD_ID,RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID,COSMOSDB_NAME,COSMOSDB_LOCATION,VIRTUAL_NETWORK_FILTER_ENABLED,VIRTUAL_NETWORK_FILTER_ENABLED_VIOLATION_FLAG"
}

# Output resource group information
function output_cosmosdb_helper() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_cosmosdb_vault
    fi
}

function output_cosmosdb_vault() {
    if [[ $CSV == "True" ]]; then
        output_cosmosdb_csv
    else
        output_cosmosdb_text
    fi
}

# Output CosmosDB information in CSV format
function output_cosmosdb_csv() {
    echo "$SUBSCRIPTION_NAME,$SUBSCRIPTION_STATE,$SUBSCRIPTION_ID,$RESOURCE_GROUP_NAME,$RESOURCE_GROUP_LOCATION,$RESOURCE_GROUP_APPLICATION_CODE,$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE,$RESOURCE_GROUP_PAR,$RESOURCE_GROUP_REQUESTOR_AD_ID,$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID,$COSMOSDB_NAME,$COSMOSDB_LOCATION,$VIRTUAL_NETWORK_FILTER_ENABLED,$VIRTUAL_NETWORK_FILTER_ENABLED_VIOLATION_FLAG"
}

# Output CosmosDB information in text format
function output_cosmosdb_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Resource Group Location: $RESOURCE_GROUP_LOCATION"
    echo "Resource Group Application Code: $RESOURCE_GROUP_APPLICATION_CODE"
    echo "Resource Group Department Charge Code: $RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE"
    echo "Resource Group PAR: $RESOURCE_GROUP_PAR"
    echo "Resource Group Requestor AD ID: $RESOURCE_GROUP_REQUESTOR_AD_ID"
    echo "Resource Group Requestor Employee ID: $RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID"
    echo "Cosmos DB Name: $COSMOSDB_NAME"
    echo "Cosmos DB Location: $COSMOSDB_LOCATION"
    echo "Cosmos DB Virutal Network Filter Enabled: $VIRTUAL_NETWORK_FILTER_ENABLED"
    echo "Cosmos DB Virutal Network Filter Enabled Violation Flag: $VIRTUAL_NETWORK_FILTER_ENABLED_VIOLATION_FLAG"
    echo $BLANK_LINE
}

# Include common menu
source ./includes/common-menu.inc

# Get subscriptions
SUBSCRIPTIONS="$(get_subscriptions "$p_SUBSCRIPTION_ID")"
output_debug_info "" "" "Subscriptions" "$SUBSCRIPTIONS";

check_if_subscriptions_exists "$SUBSCRIPTIONS"

output_header

# Process each subscription
echo "$SUBSCRIPTIONS" | jq -rc '.[]' | while IFS='' read -r SUBSCRIPTION; do
    output_debug_info "" "" "Subscription" "$SUBSCRIPTION"

    parse_subscription "$SUBSCRIPTION"

    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups "$SUBSCRIPTION_NAME" "$p_RESOURCE_GROUP_NAME")
    output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Groups" "$RESOURCE_GROUPS"

    if [[ $RESOURCE_GROUPS != "[]" ]]; then
        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do
            output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Group" "$RESOURCE_GROUP"
            parse_resource_group "$RESOURCE_GROUP"

            COSMOSDBS=$(get_cosmosdbs "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "CosmosDB" "$COSMOSDBS"
            
            if [[ "$COSMOSDBS" != "[]" ]]; then
                echo "$COSMOSDBS" | jq -rc '.[]' | while IFS='' read -r COSMOSDB; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "CosmosDB" "$COSMOSDB"
                    parse_cosmosdb_name "$COSMOSDB"

                    COSMOSDB_DETAILS=$(get_cosmosdb_details "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$COSMOSDB_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "CosmosDB Dtails" "$COSMOSDB_DETAILS"

                    parse_cosmosdb_full "$COSMOSDB_DETAILS"

                    output_cosmosdb_helper

                done # End of CosmosDB Accounts loop
            else
                output_user_info "No CosmosDB Accounts found in resource group $RESOURCE_GROUP_NAME"
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop