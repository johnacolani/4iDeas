#!/bin/bash

# Script to add 4iDeas local hostname to /etc/hosts
# Run this script with: sudo ./setup_local_host.sh

HOSTNAME="4ideas.local"
IP="127.0.0.1"

# Check if entry already exists
if grep -q "$HOSTNAME" /etc/hosts; then
    echo "Entry for $HOSTNAME already exists in /etc/hosts"
    grep "$HOSTNAME" /etc/hosts
else
    echo "Adding $IP $HOSTNAME to /etc/hosts"
    echo "$IP    $HOSTNAME" | sudo tee -a /etc/hosts
    echo "✓ Added $HOSTNAME -> $IP"
    echo ""
    echo "You can now access your app at: http://$HOSTNAME"
    echo "Run your Flutter app with: flutter run -d chrome --web-hostname=$HOSTNAME --web-port=8080"
fi






