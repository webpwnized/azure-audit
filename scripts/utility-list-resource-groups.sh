#!/bin/bash

# Source common constants and functions
source ./common-constants.inc
source ./functions.inc

# Output header based on CSV flag
function output_header() {
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Output CSV header
function output_csv_header() {
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"RESOURCE_GROUP_LOCATION\",\"RESOURCE_GROUP_APPLICATION_CODE\",\"RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"RESOURCE_GROUP_PAR\",\"RESOURCE_GROUP_REQUESTOR_AD_ID\",\"RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"MEMBERS\""
}

# Output resource group information
function output_resource_group() {
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_resource_group_helper
    fi
}

# Determine output format and call appropriate function for resource group
function output_resource_group_helper() {
    if [[ $CSV == "True" ]]; then
        output_resource_group_csv
    else
        output_resource_group_text
    fi
}

# Output resource group information in CSV format
function output_resource_group_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$RESOURCE_GROUP_LOCATION\",\"$RESOURCE_GROUP_APPLICATION_CODE\",\"$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE\",\"$RESOURCE_GROUP_PAR\",\"$RESOURCE_GROUP_REQUESTOR_AD_ID\",\"$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID\",\"$MEMBERS\""
}

# Output resource group information in text format
function output_resource_group_text() {
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
	echo "Members: $MEMBERS"
    echo $BLANK_LINE
}

# Parse resource group information
function parse_resource_group() {
    RESOURCE_GROUP_NAME=$(echo $RESOURCE_GROUP | jq -rc '.name')
    RESOURCE_GROUP_LOCATION=$(echo $RESOURCE_GROUP | jq -rc '.location')
    RESOURCE_GROUP_APPLICATION_CODE=$(echo $RESOURCE_GROUP | jq -rc '.tags.applicationCode')
    RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(echo $RESOURCE_GROUP | jq -rc '.tags.departmentChargeCode')
    RESOURCE_GROUP_PAR=$(echo $RESOURCE_GROUP | jq -rc '.tags.par')
    RESOURCE_GROUP_REQUESTOR_AD_ID=$(echo $RESOURCE_GROUP | jq -rc '.tags.requestorAdId')
    RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(echo $RESOURCE_GROUP | jq -rc '.tags.requestorEmployeeId')  
}

# Parse subscription information
function parse_subscription() {
    SUBSCRIPTION_NAME=$(echo $SUBSCRIPTION | jq -rc '.displayName')
    SUBSCRIPTION_STATE=$(echo $SUBSCRIPTION | jq -rc '.state')
    SUBSCRIPTION_ID=$(echo $SUBSCRIPTION | jq -rc '.subscriptionId')
}

# Source common menu
source ./common-menu.inc

# Get subscriptions
SUBSCRIPTIONS=$(get_subscriptions $p_SUBSCRIPTION_ID)

# Debugging information
if [[ $DEBUG == "True" ]]; then
    echo "Subscriptions (JSON): $SUBSCRIPTIONS"
fi

# Check if subscriptions exist
if [[ $SUBSCRIPTIONS != "[]" ]]; then
    # Output header if CSV format is enabled
    output_header
    
    # Process each subscription
    echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
        # Parse subscription information
        parse_subscription
        
        # Get resource groups for the subscription
        declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME)

        if [[ $DEBUG == "True" ]]; then
            echo "Resources Groups (JSON): $RESOURCE_GROUPS"
        fi

        # Process each resource group
        if [[ $RESOURCE_GROUPS != "[]" ]]; then
            echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do
                # Parse resource group information
                parse_resource_group
                
				# Get role assignments and store in a variable
				ROLE_ASSIGNMENTS=$(get_resource_group_role_assignments "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")

				# Initialize MEMBERS variable
				MEMBERS=""

				# Iterate through each role assignment using a while loop
				while IFS='' read -r ROLE_ASSIGNMENT; do
					PRINCIPLE_TYPE=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.principalType')

					if [[ $PRINCIPLE_TYPE == "User" ]]; then
						PRINCIPLE_NAME=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.principalName')
						MEMBERS="$MEMBERS$PRINCIPLE_NAME;"
					elif [[ $PRINCIPLE_TYPE == "Group" ]]; then
						GROUP_NAME=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.principalName')
						ROLE=$(echo "$ROLE_ASSIGNMENT" | jq -rc '.roleDefinitionName')
						GROUP_MEMBERS=$(get_group_members_serialized "$GROUP_NAME")

						if [[ $GROUP_MEMBERS != "" ]]; then
							MEMBERS="$MEMBERS$GROUP_MEMBERS;"
						fi
					fi   
				done <<< "$(echo "$ROLE_ASSIGNMENTS" | jq -rc '.[]')"

                # Output resource group details
                output_resource_group
            done
        else
            # Print message if no resource groups found for subscription
            if [[ $CSV != "True" ]]; then
                echo "No resource groups found for subscription $SUBSCRIPTION_NAME"
                echo $BLANK_LINE
            fi
        fi
    done
else
    # Print message if no subscriptions found
    if [[ $CSV != "True" ]]; then
        echo "No subscriptions found"
        echo $BLANK_LINE
    fi
fi
