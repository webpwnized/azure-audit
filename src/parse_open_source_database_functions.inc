#!/bin/bash

function parse_postgres_server() {
    local l_POSTGRES_SERVER=$1
    
    # Parse SQL server information from JSON
    DATABASE_SERVER_NAME=$(jq -rc '.name // ""' <<< "$l_POSTGRES_SERVER")
    DATABASE_SERVER_TYPE=$(jq -rc '.type // ""' <<< "$l_POSTGRES_SERVER")
    DATABASE_SERVER_LOCATION=$(jq -rc '.location // ""' <<< "$l_POSTGRES_SERVER")
    DATABASE_SERVER_FQDN=$(jq -rc '.properties.fullyQualifiedDomainName // ""' <<< "$l_POSTGRES_SERVER")
    DATABASE_SERVER_VERSION=$(jq -rc '.properties.version // ""' <<< "$l_POSTGRES_SERVER")
    DATABASE_SERVER_ADMIN_USERNAME=$(jq -rc '.properties.administratorLogin // ""' <<< "$l_POSTGRES_SERVER")
    DATABASE_SERVER_TLS_ENFORCED=$(jq -rc '.properties.sslEnforcement // ""' <<< "$l_POSTGRES_SERVER")
}

function parse_postgres_server_firewall_rule() {
    local l_POSTGRES_SERVER_FIREWALL_RULE=$1

    POSTGRES_SERVER_FIREWALL_RULE_NAME=$(jq -rc '.name // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_FIREWALL_RULE_START_IP_ADDRESS=$(jq -rc '.properties.startIpAddress // ""' <<< "$l_POSTGRES_SERVER")
    POSTGRES_SERVER_FIREWALL_RULE_END_IP_ADDRESS=$(jq -rc '.properties.endIpAddress // ""' <<< "$l_POSTGRES_SERVER")
}
