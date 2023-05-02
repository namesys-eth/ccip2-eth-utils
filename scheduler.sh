#!/bin/bash

# Get database config
source ./.env

# Function to run IPNS pin add command
function PIN_IPNS {
  IPNS=$1
  ipfs pin add "$IPNS"
}

# Main loop
while true
do
  # Get current timestamp and 24 hours ago timestamp
  CURRENT_TIMESTAMP=$(date +%s)
  ONE_DAY_AGO=$(($CURRENT_TIMESTAMP - 86400))

  # Get IPNS values and timestamps between 24 hours - 10 minutes and 24 hours + 10 minutes
  IPNS_TIMESTAMPS=$(mysql -u $(MYSQL_USER) -p$(MYSQL_PASSWORD) -D $(MYSQL_DATABASE) -e "SELECT IPNS, timestamp FROM events WHERE timestamp BETWEEN $((ONE_DAY_AGO - 600)) AND $((ONE_DAY_AGO + 600))")

  # Loop through each IPNS and pin it
  while read -r IPNS_TIMESTAMP
  do
    IPNS=$(echo "$IPNS_TIMESTAMP" | awk '{print $1}')
    TIMESTAMP=$(echo "$IPNS_TIMESTAMP" | awk '{print $2}')
    if [ -n "$IPNS" ]
    then
      # Run PIN_IPNS function in background thread
      PIN_IPNS "$IPNS" &
    fi
  done <<< "$IPNS_TIMESTAMPS"

  # Wait 10 minutes before repeating the loop
  sleep 600
done
