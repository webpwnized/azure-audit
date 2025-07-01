#!/bin/bash

# Function to parse subscription information
function parse_subscription() {
    local l_SUBSCRIPTION=$1
    SUBSCRIPTION_NAME=$(jq -rc '.displayName // ""' <<< "$l_SUBSCRIPTION")
    SUBSCRIPTION_STATE=$(jq -rc '.state // empty' <<< "$l_SUBSCRIPTION")
    SUBSCRIPTION_ID=$(jq -rc '.subscriptionId // ""' <<< "$l_SUBSCRIPTION")
}

# Function to parse resource group information
function parse_resource_group() {
    local l_RESOURCE_GROUP=$1

    # Parse resource group information from JSON
    RESOURCE_GROUP_NAME=$(jq -r '.name' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_LOCATION=$(jq -rc '.location // "NA"' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_APPLICATION_CODE=$(jq -r '.tags.applicationCode // "NA"' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_DEPARTMENT_CHARGE_CODE=$(jq -r '.tags.departmentChargeCode // "NA"' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_PAR=$(jq -r '.tags.par // "NA"' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_REQUESTOR_AD_ID=$(jq -r 'if .tags then .tags | with_entries(.key |= ascii_downcase) | .requestoradid // "NA" else "NA" end' <<< "$l_RESOURCE_GROUP")
    RESOURCE_GROUP_REQUESTOR_EMPLOYEE_ID=$(jq -r 'if .tags then .tags | with_entries(.key |= ascii_downcase) | .requestoremployeeid // "NA" else "NA" end' <<< "$l_RESOURCE_GROUP")
}

# Function to process role assignments
function parse_role_assignments() {
    l_ROLE_ASSIGNMENTS=$1

    # Initialize associative array to store unique members
    declare -A unique_members

    # Iterate through each role assignment using a while loop
    while IFS='' read -r ROLE_ASSIGNMENT; do
        
        output_debug_info "Role Assignment (JSON): $ROLE_ASSIGNMENT"

        PRINCIPLE_TYPE=$(jq -rc '.principalType // empty' <<< "$ROLE_ASSIGNMENT")
        ROLE_NAME=$(jq -rc '.roleDefinitionName // empty' <<< "$ROLE_ASSIGNMENT")
        
        if [[ $PRINCIPLE_TYPE == "User" ]]; then
            PRINCIPLE_NAME=$(jq -rc '.principalName // empty' <<< "$ROLE_ASSIGNMENT")
            unique_members["$PRINCIPLE_NAME"]=1  # Store unique user in the associative array
        elif [[ $PRINCIPLE_TYPE == "Group" ]]; then
            GROUP_NAME=$(jq -rc '.principalName // empty' <<< "$ROLE_ASSIGNMENT")
            GROUP_MEMBERS=$(get_group_members_serialized "$GROUP_NAME")

            # Split group members and add unique members to the associative array
            IFS=';' read -ra members_array <<< "$GROUP_MEMBERS"
            for member in "${members_array[@]}"; do
                unique_members["$member"]=1
            done
        fi
    done <<< "$(echo "$l_ROLE_ASSIGNMENTS" | jq -rc '.[]')"

    # Concatenate unique members from the associative array
    MEMBERS=""
    for member in "${!unique_members[@]}"; do
        MEMBERS+="$member;"
    done
}
