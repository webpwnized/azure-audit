#!/bin/bash

# Output debug information
function output_debug_info() {
    # Check if debug mode is enabled
    if [[ $DEBUG == "True" && $CSV == "False" ]]; then
        echo "$1"
        echo $BLANK_LINE
    fi
}

# Output message to user
function output_user_info() {
    # Check if debug mode is enabled
    if [[ $CSV == "False" ]]; then
        echo "$1"
        echo $BLANK_LINE
    fi
}

# Function to encode output for use in CSV files
function encode_for_csv() {
    local input="$1"
    local output="$input"

    # Escape double quotes by replacing them with two double quotes
    output="${output//\"/\"\"}"

    # If the string contains commas, double quotes, or newlines, wrap it in double quotes
    if [[ "$output" =~ [,\"$'\n'] ]]; then
        output="\"$output\""
    fi

    echo "$output"
}

function get_org_info_from_whois() {
    local IP_ADDRESS="$1"

    # Get whois information for the IP address
    local WHOIS_OUTPUT
    local ORG_NAME
    local ORG_COUNTRY
    local ORG_DESCRIPTION
    local ORG_CITY
    local ORG_STATE
    local ORG_ZIP

    WHOIS_OUTPUT=$(whois "$IP_ADDRESS")
    
    ORG_NAME=$(echo "$WHOIS_OUTPUT" | grep -i 'org-name\|OrgName\|organization\|Org\|owner' | head -n 1 | awk -F: '{print $2}' | xargs)
    ORG_DESCRIPTION=$(echo "$WHOIS_OUTPUT" | grep -i 'desc\|Description\|descr' | head -n 1 | awk -F: '{print $2}' | xargs)
    ORG_COUNTRY=$(echo "$WHOIS_OUTPUT" | grep -i 'country\|Country\|c\|CountryCode' | head -n 1 | awk -F: '{print $2}' | xargs)
    ORG_CITY=$(echo "$WHOIS_OUTPUT" | grep -i 'city\|City\|locality\|Locality' | head -n 1 | awk -F: '{print $2}' | xargs)
    ORG_STATE=$(echo "$WHOIS_OUTPUT" | grep -i 'state\|State\|region\|Region\|province\|Province' | head -n 1 | awk -F: '{print $2}' | xargs)
    ORG_ZIP=$(echo "$WHOIS_OUTPUT" | grep -i 'zip\|Zip\|postal\|Postal\|postcode\|Postcode' | head -n 1 | awk -F: '{print $2}' | xargs)

    # If the output is empty, assign a default value
    ORG_NAME="${ORG_NAME:-Unknown}"
    ORG_DESCRIPTION="${ORG_DESCRIPTION:-Unknown}"
    ORG_COUNTRY="${ORG_COUNTRY:-Unknown}"
    ORG_CITY="${ORG_CITY:-Unknown}"
    ORG_STATE="${ORG_STATE:-Unknown}"
    ORG_ZIP="${ORG_ZIP:-Unknown}"
    
    # Encode for CSV and combine results
    local ENCODED_OUTPUT=$(encode_for_csv "$ORG_NAME-$ORG_DESCRIPTION-$ORG_CITY-$ORG_STATE-$ORG_ZIP-$ORG_COUNTRY")
    echo "$ENCODED_OUTPUT"
}