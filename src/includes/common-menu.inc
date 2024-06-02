#!/bin/bash

# Declare variables for subscription and resource group
declare p_SUBSCRIPTION="";
declare p_RESOURCE_GROUP="";

# Declare variables for debug, csv flags
declare DEBUG="False";
declare CSV="False";

# Declare a variable for help message
declare HELP=$(cat << EOL
Usage: $0 [OPTIONS]

Options:
  -h, --help                       Show this help message and exit.
  -d, --debug                      Enable debug mode. Provides detailed output for troubleshooting.
  -c, --csv                        Output results in CSV format.
  -s <SUBSCRIPTION_ID>, --subscription <SUBSCRIPTION_ID>
                                   Specify the Azure subscription ID to use.
  -r <RESOURCE_GROUP_NAME>, --resource-group <RESOURCE_GROUP_NAME>
                                   Specify the Azure resource group name.

Examples:
  $0 -s your-subscription-id -r your-resource-group
      Perform checks on the specified subscription and resource group.
  $0 --debug --csv
      Enable debug mode and output results in CSV format.

Description:
This script performs various checks on Azure Cloud resource groups. 
You can specify the Azure subscription and resource group to target, 
enable debug mode for more detailed output, and output results in CSV 
format.
EOL
);

# Loop through all arguments
for arg in "$@"; do
  shift
  # Match argument to its short form
  case "$arg" in
    "--help")              set -- "$@" "-h" ;;
    "--debug")             set -- "$@" "-d" ;;
    "--csv")               set -- "$@" "-c" ;;
    "--subscription")      set -- "$@" "-s" ;;
    "--resource-group")    set -- "$@" "-r" ;;
    *)                     set -- "$@" "$arg"
  esac
done

# Process all short form arguments
while getopts "hdcs:r:" option
do 
    case "${option}" in
        d)
            # Set debug flag to true
            DEBUG="True";;
        c)
            # Set csv flag to true
            CSV="True";;
        h)
            # Print help message and exit
            echo "$HELP"; 
            exit 0;;
        s)
            # Set subscription id
            p_SUBSCRIPTION_ID="${OPTARG}";;
        r)
            # Set resource group name
            p_RESOURCE_GROUP_NAME="${OPTARG}";;
    esac;
done;