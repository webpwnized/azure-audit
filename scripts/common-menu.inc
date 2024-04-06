#!/bin/bash

declare p_SUBSCRIPTION="";
declare p_RESOURCE_GROUP="";

declare DEBUG="False";
declare CSV="False";
declare HELP=$(cat << EOL
	$0 [-c, --csv] [-d, --debug] [-h, --help] [-s <SUBSCRIPTION_ID>, --subscription <SUBSCRIPTION_ID> ] [-r <RESOURCE_GROUP_NAME>, --resource-group <RESOURCE_GROUP_NAME>]
EOL
);

for arg in "$@"; do
  shift
  case "$arg" in
    "--help") 			set -- "$@" "-h" ;;
    "--debug") 			set -- "$@" "-d" ;;
    "--csv") 			set -- "$@" "-c" ;;
    "--subscription")		set -- "$@" "-s" ;;
    "--resource-group") 	set -- "$@" "-r" ;;
    *)        			set -- "$@" "$arg"
  esac
done

while getopts "hdcs:r:" option
do 
    case "${option}" in
        d)
        	DEBUG="True";;
        c)
        	CSV="True";;
        h)
        	echo $HELP; 
        	exit 0;;
        s)
        	p_SUBSCRIPTION_ID="${OPTARG}";;
        r)
        	p_RESOURCE_GROUP_NAME="${OPTARG}";;
    esac;
done;

