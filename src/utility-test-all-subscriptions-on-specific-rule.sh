#!/bin/bash

#note: to filter further --> uncomment any or none of the if statements below
#note: can add more filters below to speed it up
    #ie: test to see if a subscription has any sql server groups at all instead of testing in each resource of that subscription

#compiling: chmod +x utility-test-all-subscriptions-on-specific-rule.sh && chmod +x cis-10.1-ensure-auditing-set-on-for-azure-sql-servers.sh
#example: ./utility-test-all-subscriptions-on-specific-rule.sh -n ./cis-10.1-ensure-auditing-set-on-for-azure-sql-servers.sh

declare p_NAME_Of_SCRIPT=""; #had to use this and not the common-menu because it didn't work for some reason(ie: only write everything in one file)

while getopts "n:" option
do 
    case "${option}" in
        n)
            # Set name of the script
            p_NAME_Of_SCRIPT="${OPTARG}";;
    esac;
done;

script_name=$p_NAME_Of_SCRIPT

if [[ -z "$script_name" ]]; then
  echo "❌ script_name is not set. Exiting."
  exit 1
fi

log_dir="./logs"
mkdir -p "$log_dir"

# Get all subscription IDs
subscriptions=$(az account list --query "[].id" -o tsv) #this is limiting what subscriptions to grab: can fix this with adding --all(ie: az account list --query "[].id" -o tsv --all) but this is inconsistent with what is being used throuhgout the other scripts, thoughts?

if [[ -z "$subscriptions" ]]; then
    echo "❌ No subscriptions found. Make sure you're logged in with 'az login'."
    exit 1
fi

echo "🔁 Running tests across all subscriptions and resource groups..."
echo "Logging output to $log_dir"

subscriptions_array=($subscriptions)
total_subs=${#subscriptions_array[@]}
current=1

for subscription in "${subscriptions_array[@]}"; do
    echo "🔷 [$current/$total_subs] Switching to subscription: $subscription"
    ((current++))

    az account set --subscription "$subscription"

    # Get resource groups in this subscription
    resource_groups=$(az group list --query "[].name" -o tsv)

    if [[ -z "$resource_groups" ]]; then
        echo "⚠️ No resource groups found in subscription: $subscription"
        continue
    fi

    # Loop through resource groups
    for rg in $resource_groups; do
        echo "▶️ Running test for $subscription / $rg"

        #uncomment below if want to filter further for cis: 10.1
        sql_server_groups=$(az sql server list --subscription="$subscription" --resource-group="$rg")
        if [[ "$sql_server_groups" == "[]" ]]; then
            echo "⚠️ No sql server groups found in subscription: $subscription & resource group: $rg"
            continue
        fi

        #uncomment below if want to filter further for cis: 9.3.7
        # key_vault_group=$(az keyvault list --subscription="$subscription" --resource-group="$rg")
        # if [[ "$key_vault_group" == "[]" ]]; then
        #     echo "⚠️ No key vault groups found in subscription: $subscription & resource group: $rg"
        #     continue
        # fi

        log_file="${log_dir}/${subscription}_${rg}.log"
        $script_name --subscription "$subscription" --resource-group "$rg" > "$log_file" 2>&1 #might need --debug

        echo "✅ Completed: $subscription / $rg"
        echo "📝 Output logged to $log_file"
        echo "-------------------------------------------------------------------------"
    done
done

echo "🎉 All tests completed."
