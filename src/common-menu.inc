#!/bin/bash

# Declare variables for subscription and resource group
declare p_SUBSCRIPTION="";
declare p_RESOURCE_GROUP="";

# Declare variables for debug and csv flags
declare DEBUG="False";
declare CSV="False";

# Declare a variable for help message
declare HELP=$(cat << EOL
    $0 [-c, --csv] [-d, --debug] [-h, --help] [-s <SUBSCRIPTION_ID>, --subscription <SUBSCRIPTION_ID> ] [-r <RESOURCE_GROUP_NAME>, --resource-group <RESOURCE_GROUP_NAME>]
EOL
);

# Loop through all arguments
for arg in "$@"; do
  shift
  # Match argument to its short form
  case "$arg" in
    "--help") 			set -- "$@" "-h" ;;
    "--debug") 			set -- "$@" "-d" ;;
    "--csv") 			set -- "$@" "-c" ;;
    "--subscription")		set -- "$@" "-s" ;;
    "--resource-group") 	set -- "$@" "-r" ;;
    *)        			set -- "$@" "$arg"
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
            echo $HELP; 
            exit 0;;
        s)
            # Set subscription id
            p_SUBSCRIPTION_ID="${OPTARG}";;
        r)
            # Set resource group name
            p_RESOURCE_GROUP_NAME="${OPTARG}";;
    esac;
done;