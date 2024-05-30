#!/bin/bash

# Function to check if traffic is allowed from the internet
function is_traffic_allowed_from_internet() {
    [[ "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" =~ ^(?!10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.).*$ || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "*" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "0.0.0.0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "<nw>/0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "/0" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Internet" || 
       "$SECURITY_RULE_SOURCE_ADDRESS_PREFIX" == "Any" ]]
}

# Function to check if the security rule matches a specific protocol and destination port
function is_port_and_protocol_matched() {
    [[ "$SECURITY_RULE_PROTOCOL" == "$1" || "$SECURITY_RULE_PROTOCOL" == "*" ]] && 
    [[ "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "$2" || "$SECURITY_RULE_DESTINATION_PORT_RANGE" == "*" || "$SECURITY_RULE_DESTINATION_PORT_RANGES" == *"$2"* ]]
}
