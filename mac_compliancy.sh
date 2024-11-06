#!/usr/bin/env bash

hostname=$(scutil --get ComputerName)
username=$USER
date=$(date)
shasum=$(shasum -a mac_compliancy.sh)
echo "Hostname: $hostname"
echo "Username: $username"
echo "Date and Time: $date"
echo "sha256sum: $shasum"

echo "Checking macOS security status..."

echo -n "Antivirus (Gatekeeper) is "
if spctl --status 2>/dev/null | grep -q "assessments enabled"; then
    echo "activated."
else
    echo "not activated."
fi

echo -n "Firewall is "
FIREWALL_STATUS=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
if echo "$FIREWALL_STATUS" | grep -q "enabled"; then
    echo "activated."
else
    echo "not activated."
fi

echo -n "Auto Update is "
AUTO_UPDATE=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null)
if [ "$AUTO_UPDATE" == "1" ]; then
    echo "activated."
else
    echo "not activated."
fi

echo -n "Hard drive encryption (FileVault) is "
FV_STATUS=$(fdesetup status 2>/dev/null)
if echo "$FV_STATUS" | grep -q "FileVault is On."; then
    echo "on."
else
    echo "off."
fi
