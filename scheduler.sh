#!/bin/bash

# Get database config
source ./.env

# Function to run ipns pin add command
function pin_ipns {
  ipns=$1
  ipns pin add "$ipns"
}

# Main loop
while true
do
  # Get current timestamp and 24 hours ago timestamp
  current_timestamp=$(date +%s)
  twenty_four_hours_ago=$(($current_timestamp - 86400))

  # Get IPNS values and timestamps between 24 hours - 10 minutes and 24 hours + 10 minutes
  ipns_timestamps=$(mysql -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) -D $(MYSQL_DATABASE) -e "SELECT IPNS, timestamp FROM events WHERE timestamp BETWEEN $((twenty_four_hours_ago - 600)) AND $((twenty_four_hours_ago + 600))")

  # Loop through each IPNS and pin it
  while read -r ipns_timestamp
  do
    ipns=$(echo "$ipns_timestamp" | awk '{print $1}')
    timestamp=$(echo "$ipns_timestamp" | awk '{print $2}')
    if [ -n "$ipns" ]
    then
      # Run pin_ipns function in background thread
      pin_ipns "$ipns" &
    fi
  done <<< "$ipns_timestamps"

  # Wait 10 minutes before repeating the loop
  sleep 600
done
