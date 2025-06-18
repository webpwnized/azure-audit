#!/bin/bash

# Reference: 
# https://learn.microsoft.com/en-us/azure/azure-sql/database/security-overview?view=azuresql
# reference: 8.3 Ensure that UDP access from the Internet is evaluated and restricted (Automated) - Networking Serivces - CIS_Microsoft_Azure_Foundations_Benchmark_v4.0.0.pdf
# note: 8.1 already checks for 8.3, so just run 8.1

# Debug: ./cis-8.3-ensure-UDP-restricted.sh

chmod +x cis-8.1-ensure-rdp-restricted.sh
./cis-8.1-ensure-rdp-restricted.sh -s 1014e3e6-e0cf-44c0-8efe-ba17d0c6e3ed -r rg-scd-prd