#!/bin/bash

# Reference: 4.1.1 Ensure only MFA enabled identities can access privileged Virtual Machine (Manual) - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0.pdf

# Debug: ./cis-4.1.1-ensure-only-mfa-enabled-identities-access-privileged-vm.sh -s tbd -r tbd

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
    echo "\"SUBSCRIPTION_NAME\",\"SUBSCRIPTION_STATE\",\"SUBSCRIPTION_ID\",\"RESOURCE_GROUP_NAME\",\"PRINCIPAL_NAME\",\"PRINCIPAL_ID\",\"PRINCIPAL_TYPE\"\"ASSIGNED_ROLE\"\"ASSIGNMENT_SCOPE\"\"ROLE_NAME\",\"MFA_STATUS\",\"MFA_ENFORCED\",\"EXEMPT_POLICY\",\"MFA_STATUS_Violation\""
}

# Output resource group information
function output_mfa_list_helper() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_mfa_list
    fi
}

function output_mfa_list() {
    if [[ $CSV == "True" ]]; then
        output_mfa_list_csv
    else
        output_mfa_list_text
    fi
}

# Output Key Vault information in CSV format
function output_mfa_list_csv() {
    echo "\"$SUBSCRIPTION_NAME\",\"$SUBSCRIPTION_STATE\",\"$SUBSCRIPTION_ID\",\"$RESOURCE_GROUP_NAME\",\"$PRINCIPAL_NAME\",\"$PRINCIPAL_ID\",\"$PRINCIPAL_TYPE\"\"$ASSIGNED_ROLE\"\"$ASSIGNMENT_SCOPE\"\"$ROLE_NAME\",\"$MFA_STATUS\",\"$MFA_ENFORCED\",\"$EXEMPT_POLICY\",\"$MFA_STATUS_Violation\""
}

# Output Key Vault information in text format
function output_mfa_list_text() {
    echo "Subscription Name: $SUBSCRIPTION_NAME"
    echo "Subscription State: $SUBSCRIPTION_STATE"
    echo "Subscription ID: $SUBSCRIPTION_ID"
    echo "Resource Group Name: $RESOURCE_GROUP_NAME"
    echo "Principal Name: $PRINCIPAL_NAME"
    echo "Principal Id: $PRINCIPAL_ID"
    echo "Principal Type: $PRINCIPAL_TYPE"
    echo "Assigned Role: $ASSIGNED_ROLE"
    echo "Assignment : $ASSIGNMENT_SCOPE"
    echo "Role Name: $ROLE_NAME"
    echo "MFA Status: $MFA_STATUS"
    echo "MFA Enforced: $MFA_ENFORCED"
    echo "Exempt Policy: $EXEMPT_POLICY"
    echo "MFA Status Violation: $MFA_STATUS_Violation"
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

            ROLE_ASSIGNMENTS=$(get_role_assignments "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Role Assignments" "$ROLE_ASSIGNMENTS"
            
            if [[ "$ROLE_ASSIGNMENTS" != "[]" ]]; then
                echo "$ROLE_ASSIGNMENTS" | jq -rc '.[]' | while IFS='' read -r ROLE_ASSIGNMENT; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Role Assignment" "$ROLE_ASSIGNMENT"
                    parse_mfa_role_assignment "$ROLE_ASSIGNMENT"

                    MFA_STATUS="unknown"
                    MFA_STATUS_Violation="unknown"
                    EXEMPT_POLICY="unknown"

                    MFA_ENFORCED=$(get_mfa_enforced "$PRINCIPAL_NAME")
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "MFA Enforced" "$MFA_ENFORCED"

                    if [[ $MFA_ENFORCED == "Enabled" ]]; then
                        MFA_STATUS="Enabled"
                        VIOLATION_FLAG="False"
                        EXEMPT_POLICY="NA"
                    else
                        EXEMPT_POLICY=$(get_mfa_exempt_policy "$PRINCIPAL_NAME")
                        output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Exempt Policy" "$EXEMPT_POLICY"

                        if [[ $EXEMPT_POLICY == "[]" ]]; then
                            MFA_STATUS="Conditional Access - Included"
                            VIOLATION_FLAG="False"
                        else
                            MFA_STATUS="Not Enforced"
                            VIOLATION_FLAG="True"
                        fi
                    fi

                    output_mfa_list_helper

                done # End of role assignment loop
            else
                output_user_info "No Redis Lists found in resource group $RESOURCE_GROUP_NAME"
            fi
        done # End of resource group loop
    else
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop
