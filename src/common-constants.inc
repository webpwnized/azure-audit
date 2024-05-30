#!/bin/bash

declare BLANK_LINE="";

# Function to check if a command is installed
is_command_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Check if sqlcmd is installed, then set the flag
if is_command_installed sqlcmd; then
    SQL_SERVER_SQLCMD_INSTALLED="True"
else
    SQL_SERVER_SQLCMD_INSTALLED="False"
fi

# Check if sqlcmd is installed, then set the flag
if is_command_installed whois; then
    WHOIS_INSTALLED="True"
else
    WHOIS_INSTALLED="False"
fi

# Check if sqlcmd is installed, then set the flag
if is_command_installed curl; then
   CURL_INSTALLED="True"
else
    CURL_INSTALLED="False"
fi