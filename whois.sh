#!/bin/bash

if ! command -v whois &> /dev/null; then
    echo "Error: 'whois' command not found. Please install it and try again."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 domain_name [output_file]"
    exit 1
fi

DOMAIN=$1
OUTPUT_FILE=${2:-/dev/stdout}

echo "Getting WHOIS information for $DOMAIN..."

whois_result=$(whois "$DOMAIN")

reg_date=$(echo "$whois_result" | awk -F ': +' '/Creation Date/ {gsub(/[-T]/," ",$2); split($2, date, " "); print date[3]"-"date[2]"-"date[1]}')
exp_date=$(echo "$whois_result" | awk -F ': +' '/Registry Expiry Date/ {gsub(/[-T]/," ",$2); split($2, date, " "); print date[3]"-"date[2]"-"date[1]}')
reg_status=$(echo "$whois_result" | awk -F ': +' '/Domain Status/ {print $2}')
registrar=$(echo "$whois_result" | awk -F ': +' '/Registrar:/ {print $2}')

echo -e "Domain:\t\t$DOMAIN\nRegistrar:\t$registrar\nRegistration:\t$reg_date\nExpiration:\t$exp_date\nStatus:\t\t$reg_status\nNameservers:"

nameservers=$(echo "$whois_result" | awk -F ': +' '/Name Server/ {print $2}' | head -n 5)
while read -r nameserver; do
    echo -e "\t\t$nameserver"
done <<< "$nameservers" | column -t -s $'\t' | sed 's/^/    /'

if [ "$OUTPUT_FILE" != "/dev/stdout" ]; then
    echo "Writing output to $OUTPUT_FILE..."
    echo -e "Domain:\t\t$DOMAIN\nRegistrar:\t$registrar\nRegistration:\t$reg_date\nExpiration:\t$exp_date\nStatus:\t\t$reg_status\nNameservers:" | cat - <(echo "$nameservers" | column -t -s $'\t' | sed 's/^/    /') > "$OUTPUT_FILE"
fi

echo "Done."
