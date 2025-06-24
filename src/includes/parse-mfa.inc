#!/bin/bash

function parse_mfa_role_assignment() {
    local role_assignment_json=$1

    PRINCIPAL_NAME=$(jq -r '.principalName // empty' <<< "$role_assignment_json")
    PRINCIPAL_ID=$(jq -r '.principalId // empty' <<< "$role_assignment_json")
    PRINCIPAL_TYPE=$(jq -r '.principalType // empty' <<< "$role_assignment_json")
    ASSIGNED_ROLE=$(jq -r '.roleDefinitionName // empty' <<< "$role_assignment_json")
    ASSIGNMENT_SCOPE=$(jq -r '.scope // empty' <<< "$role_assignment_json")
    ROLE_NAME=$(jq -r '.role // empty' <<< "$role_assignment_json")
}

