#!/bin/bash

#reference: 10.3.2.2 Ensure that 'Public Network Access' is 'Disabled' for storage accounts (Automated) - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0
#Also referenced: 17.2.2 Ensure that 'Public Network Access' is 'Disabled' for storage accounts (Automated) - CIS_Microsoft_Azure_Storage_Services_Benchmark_v1.0.0.pdf

# Debug: ./cis-10.3.2.2-ensure-public-network-disabled-storage-account.sh -s SUBSCRIPTION_ID -r RESOURCE_NAME --debug

# Source common constants and functions
source ./includes/common-constants.inc
source ./includes/common-functions.inc

# Output header based on CSV flag
function output_header() {
    # Check if CSV output is enabled
    if [[ $CSV == "True" ]]; then
        output_csv_header
    fi
}

# Output CSV header
function output_csv_header() {
    # Output CSV header line
    echo "SUBSCRIPTION_NAME,SUBSCRIPTION_STATE,SUBSCRIPTION_ID,RESOURCE_GROUP_NAME,RESOURCE_GROUP_LOCATION,RESOURCE_GROUP_APPLICATION_CODE,RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE,RESOURCE_GROUP_PAR,RESOURCE_GROUP_REQUESTOR_AD_ID,RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID,STORAGE_ACCOUNT_NAME,STORAGE_ACCOUNT_LOCATION,STORAGE_ACCOUNT_KIND,STORAGE_ACCOUNT_ALLOW_BLOB_PUBLIC_ACCESS,STORAGE_ACCOUNT_ALLOW_SHARED_KEY_ACCESS,STORAGE_ACCOUNT_AZURE_FILES_IDENTITY_BASED_AUTHENTICATION,STORAGE_ACCOUNT_ENABLE_HTTPS_ONLY,STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_BLOB,STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_DFS,STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_FILE,STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_QUEUE,STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_TABLE,STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_WEB,STORAGE_ACCOUNT_ENCRYPTION_SERVICES_BLOB_ENABLED,STORAGE_ACCOUNT_ENCRYPTION_SERVICES_FILE_ENABLED,STORAGE_ACCOUNT_ENCRYPTION_SERVICES_QUEUE_ENABLED,STORAGE_ACCOUNT_ENCRYPTION_SERVICES_TABLE_ENABLED,STORAGE_ACCOUNT_IS_LOCAL_USER_ENABLED,STORAGE_ACCOUNT_IS_FTP_ENABLED,STORAGE_ACCOUNT_MINIMUM_TLS_VERSION,STORAGE_ACCOUNT_NETWORK_RULESET_BYPASS,STORAGE_ACCOUNT_NETWORK_RULESET_IP_RULES,STORAGE_ACCOUNT_NETWORK_RULESET_VIRTUAL_NETWORK_RULES,STORAGE_ACCOUNT_NETWORK_RULESET_DEFAULT_ACTION,STORAGE_ACCOUNT_PUBLIC_NETWORK_ACCESS,STORAGE_ACCOUNT_SAS_POLICY,STORAGE_ACCOUNT_CONTAINERS,STORAGE_ACCOUNT_ALLOW_BLOB_PUBLIC_ACCESS_VIOLATION_FLAG,STORAGE_ACCOUNT_ALLOW_SHARED_KEY_ACCESS_VIOLATION_FLAG,STORAGE_ACCOUNT_ENABLE_HTTPS_ONLY_VIOLATION_FLAG,STORAGE_ACCOUNT_MINIMUM_TLS_VERSION_VIOLATION_FLAG,STORAGE_ACCOUNT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG,STORAGE_ACCOUNT_ENCRYPTION_SERVICES_VIOLATION_FLAG,STORAGE_ACCOUNT_FTP_ENABLED_VIOLATION_FLAG,STORAGE_ACCOUNT_LOCAL_USER_ENABLED_VIOLATION_FLAG"
}

# Output resource group information
function output_storage_account() {
    # Check if the resource group name doesn't start with "Visual Studio"
    if [[ $RESOURCE_GROUP_NAME != "Visual Studio"* ]]; then
        output_storage_account_helper
    fi
}

# Determine output format and call appropriate function for resource group
function output_storage_account_helper() {
    # Check if CSV output is enabled
    if [[ $CSV == "True" ]]; then
        output_storage_account_csv
    else
        output_storage_account_text
    fi
}

# Output resource group information in CSV format
function output_storage_account_csv() {
    # Output resource group details in CSV format
    echo "$SUBSCRIPTION_NAME,$SUBSCRIPTION_STATE,$SUBSCRIPTION_ID,$RESOURCE_GROUP_NAME,$RESOURCE_GROUP_LOCATION,$RESOURCE_GROUP_APPLICATION_CODE,$RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE,$RESOURCE_GROUP_PAR,$RESOURCE_GROUP_REQUESTOR_AD_ID,$RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID,$STORAGE_ACCOUNT_NAME,$STORAGE_ACCOUNT_LOCATION,$STORAGE_ACCOUNT_KIND,$STORAGE_ACCOUNT_ALLOW_BLOB_PUBLIC_ACCESS,$STORAGE_ACCOUNT_ALLOW_SHARED_KEY_ACCESS,$STORAGE_ACCOUNT_AZURE_FILES_IDENTITY_BASED_AUTHENTICATION,$STORAGE_ACCOUNT_ENABLE_HTTPS_ONLY,$STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_BLOB,$STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_DFS,$STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_FILE,$STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_QUEUE,$STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_TABLE,$STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_WEB,$STORAGE_ACCOUNT_ENCRYPTION_SERVICES_BLOB_ENABLED,$STORAGE_ACCOUNT_ENCRYPTION_SERVICES_FILE_ENABLED,$STORAGE_ACCOUNT_ENCRYPTION_SERVICES_QUEUE_ENABLED,$STORAGE_ACCOUNT_ENCRYPTION_SERVICES_TABLE_ENABLED,$STORAGE_ACCOUNT_IS_LOCAL_USER_ENABLED,$STORAGE_ACCOUNT_IS_FTP_ENABLED,$STORAGE_ACCOUNT_MINIMUM_TLS_VERSION,$STORAGE_ACCOUNT_NETWORK_RULESET_BYPASS,$(encode_for_csv "$STORAGE_ACCOUNT_NETWORK_RULESET_IP_RULES"),$(encode_for_csv "$STORAGE_ACCOUNT_NETWORK_RULESET_VIRTUAL_NETWORK_RULES"),$STORAGE_ACCOUNT_NETWORK_RULESET_DEFAULT_ACTION,$STORAGE_ACCOUNT_PUBLIC_NETWORK_ACCESS,$STORAGE_ACCOUNT_SAS_POLICY,$STORAGE_ACCOUNT_CONTAINERS,$STORAGE_ACCOUNT_ALLOW_BLOB_PUBLIC_ACCESS_VIOLATION_FLAG,$STORAGE_ACCOUNT_ALLOW_SHARED_KEY_ACCESS_VIOLATION_FLAG,$STORAGE_ACCOUNT_ENABLE_HTTPS_ONLY_VIOLATION_FLAG,$STORAGE_ACCOUNT_MINIMUM_TLS_VERSION_VIOLATION_FLAG,$STORAGE_ACCOUNT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG,$STORAGE_ACCOUNT_ENCRYPTION_SERVICES_VIOLATION_FLAG,$STORAGE_ACCOUNT_FTP_ENABLED_VIOLATION_FLAG,$STORAGE_ACCOUNT_LOCAL_USER_ENABLED_VIOLATION_FLAG"
}

# Output resource group information in text format
function output_storage_account_text() {
    # Output resource group details in text format
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
    echo "Storage Account Name: $STORAGE_ACCOUNT_NAME"
    echo "Storage Account Location: $STORAGE_ACCOUNT_LOCATION"
    echo "Storage Account Kind: $STORAGE_ACCOUNT_KIND"
    echo "Storage Account Allow Blob Public Access: $STORAGE_ACCOUNT_ALLOW_BLOB_PUBLIC_ACCESS"
    echo "Storage Account Allow Shared Key Access: $STORAGE_ACCOUNT_ALLOW_SHARED_KEY_ACCESS"
    echo "Storage Account Azure Files Identity Based Authentication: $STORAGE_ACCOUNT_AZURE_FILES_IDENTITY_BASED_AUTHENTICATION"
    echo "Storage Account Enable HTTPS Only: $STORAGE_ACCOUNT_ENABLE_HTTPS_ONLY"
    echo "Storage Account Primary Endpoints Blob: $STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_BLOB"
    echo "Storage Account Primary Endpoints DFS: $STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_DFS"
    echo "Storage Account Primary Endpoints File: $STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_FILE"
    echo "Storage Account Primary Endpoints Queue: $STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_QUEUE"
    echo "Storage Account Primary Endpoints Table: $STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_TABLE"
    echo "Storage Account Primary Endpoints Web: $STORAGE_ACCOUNT_PRIMARY_ENDPOINTS_WEB"
    echo "Storage Account Encryption Services Blob Enabled: $STORAGE_ACCOUNT_ENCRYPTION_SERVICES_BLOB_ENABLED"
    echo "Storage Account Encryption Services File Enabled: $STORAGE_ACCOUNT_ENCRYPTION_SERVICES_FILE_ENABLED"
    echo "Storage Account Encryption Services Queue Enabled: $STORAGE_ACCOUNT_ENCRYPTION_SERVICES_QUEUE_ENABLED"
    echo "Storage Account Encryption Services Table Enabled: $STORAGE_ACCOUNT_ENCRYPTION_SERVICES_TABLE_ENABLED"
    echo "Storage Account Is Local User Enabled: $STORAGE_ACCOUNT_IS_LOCAL_USER_ENABLED"
    echo "Storage Account Is FTP Enabled: $STORAGE_ACCOUNT_IS_FTP_ENABLED"
    echo "Storage Account Minimum TLS Version: $STORAGE_ACCOUNT_MINIMUM_TLS_VERSION"
    echo "Storage Account Network Ruleset Bypass: $STORAGE_ACCOUNT_NETWORK_RULESET_BYPASS"
    echo "Storage Account Network Ruleset IP Rules: $STORAGE_ACCOUNT_NETWORK_RULESET_IP_RULES"
    echo "Storage Account Network Ruleset Virtual Network Rules: $STORAGE_ACCOUNT_NETWORK_RULESET_VIRTUAL_NETWORK_RULES"
    echo "Storage Account Network Ruleset Default Action: $STORAGE_ACCOUNT_NETWORK_RULESET_DEFAULT_ACTION"
    echo "Storage Account Public Network Access: $STORAGE_ACCOUNT_PUBLIC_NETWORK_ACCESS"
    echo "Storage Account SAS Policy: $STORAGE_ACCOUNT_SAS_POLICY"
    echo "Storage Account Containers (inconclusive if empty): $STORAGE_ACCOUNT_CONTAINERS"
    echo "Storage Account Allow Blob Public Access Violation: $STORAGE_ACCOUNT_ALLOW_BLOB_PUBLIC_ACCESS_VIOLATION_FLAG"
    echo "Storage Account Allow Shared Key Access Violation: $STORAGE_ACCOUNT_ALLOW_SHARED_KEY_ACCESS_VIOLATION_FLAG"
    echo "Storage Account Enable HTTPS Only Violation: $STORAGE_ACCOUNT_ENABLE_HTTPS_ONLY_VIOLATION_FLAG"
    echo "Storage Account Minimum TLS Version Violation: $STORAGE_ACCOUNT_MINIMUM_TLS_VERSION_VIOLATION_FLAG"
    echo "Storage Account Public Network Access Violation: $STORAGE_ACCOUNT_PUBLIC_NETWORK_ACCESS_VIOLATION_FLAG"
    echo "Storage Account Encryption Services Violation: $STORAGE_ACCOUNT_ENCRYPTION_SERVICES_VIOLATION_FLAG"
    echo "Storage Account FTP Enabled Violation: $STORAGE_ACCOUNT_FTP_ENABLED_VIOLATION_FLAG"
    echo "Storage Account Local User Enabled Violation: $STORAGE_ACCOUNT_LOCAL_USER_ENABLED_VIOLATION_FLAG"
    echo $BLANK_LINE
}

# Source common menu
source ./includes/common-menu.inc

# Get subscriptions
SUBSCRIPTIONS="$(get_subscriptions "$p_SUBSCRIPTION_ID")"
output_debug_info "" "" "Subscriptions" $SUBSCRIPTIONS;

check_if_subscriptions_exists "$SUBSCRIPTIONS"

# Output header if CSV format is enabled
output_header

# Process each subscription
echo $SUBSCRIPTIONS | jq -rc '.[]' | while IFS='' read SUBSCRIPTION; do
    output_debug_info "" "" "Subscription" "$SUBSCRIPTION"
    
    # Parse subscription information
    parse_subscription "$SUBSCRIPTION"
    
    # Get resource groups for the subscription
    declare RESOURCE_GROUPS=$(get_resource_groups $SUBSCRIPTION_NAME $p_RESOURCE_GROUP_NAME)

    output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Groups" "$RESOURCE_GROUPS"

    # Process each resource group
    if [[ $RESOURCE_GROUPS != "[]" ]]; then
        echo $RESOURCE_GROUPS | jq -rc '.[]' | while IFS='' read RESOURCE_GROUP; do

            output_debug_info "$SUBSCRIPTION_NAME" "" "Resource Group" "$RESOURCE_GROUP"

            # Parse resource group information
            parse_resource_group "$RESOURCE_GROUP"
            
            STORAGE_ACCOUNTS=$(get_storage_accounts "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME")
            output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Storage Accounts" "$STORAGE_ACCOUNTS"
            
            if [[ $STORAGE_ACCOUNTS != "[]" ]]; then
                echo $STORAGE_ACCOUNTS | jq -rc '.[]' | while IFS='' read STORAGE_ACCOUNT; do
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Storage Account" "$STORAGE_ACCOUNT"
                    parse_storage_account "$STORAGE_ACCOUNT"

                    STORAGE_ACCOUNT_CONTAINERS=$(get_storage_account_containers "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "$STORAGE_ACCOUNT_NAME") 
                    output_debug_info "$SUBSCRIPTION_NAME" "$RESOURCE_GROUP_NAME" "Storage Account Containers" "$STORAGE_ACCOUNT_CONTAINERS"
                    
                    parse_storage_account_containers "$STORAGE_ACCOUNT_CONTAINERS"

                    output_storage_account
                done # End of storage account loop
            fi
        done # End of resource group loop
    else
        # Print message if no resource groups found for subscription
        output_user_info "No resource groups found for subscription $SUBSCRIPTION_NAME"
    fi
done # End of subscription loop
