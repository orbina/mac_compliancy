#!/usr/bin/env bash

hostname=$(scutil --get ComputerName)
username=$USER
date=$(date)
shasum=$(shasum -a 256 mac_compliancy.sh)
osname=$(sw_vers -productName)
osver=$(sw_vers -productVersion)
cpu=$(sysctl -n machdep.cpu.branding_string)
vendor=$(system_profiler SPHardwareDataType | awk -F ": " '/Model Name|Model Identifier/{print $2}' | xargs | sed 's/ /, /g')

ip=$(ipconfig getifaddr en0)
if [ -z "$ip" ]; then
	ip="Not connected"
fi

mac=$(ifconfig en0 | awk "/ether/print $2")
if [ -z "mac" ]; then
	mac="Not available"
fi

echo "sha256sum: $shasum"
echo "Date: $date"
echo "Hostname: $hostname"
echo "Username: $username"
echo "IP Address: $ip"
echo "Mac Address: $mac"
echo "OS: $os"
echo "OS version: $osver"
echo "HW vendor & model: $vendor"
echo "CPU: $cpu"

echo "Checking macOS security status..."

echo -n "Antivirus (Gatekeeper) is "
if spctl --status 2>/dev/null | grep -q "assessments enabled"; then
    echo "activated."
else
    echo "not activated."
fi

echo -n "Firewall is "
fwstat=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
if echo "$fwstat" | grep -q "enabled"; then
    echo "activated."
else
    echo "not activated."
fi

echo -n "Auto Update is "
autoupd=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled 2>/dev/null)
if [ "$autoupd" == "1" ]; then
    echo "activated."
else
    echo "not fully activated."
    
    echo "Running detailed checks:"
    autod=$()
    critupd=$()
    sysupd=$()
    appupd=$()

    if [ "$autod" == "1" ]; then
	   echo "- Automatic download of updates is activated."
    else
        echo "- Automatic download of updates is not activated."
    fi

    if [ "$critupd" == "1" ]; then
        echo "- Installation of critical updates is activated."
    else
        echo "- Installation of critical updates is not activated."
    fi

    if [ "$sysupd" == "1" ]; then
        echo "- Installation of system data files is activated."
    else
        echo "- Installation of system data files is not activated."
    fi

    if [ "$appupd" == "1" ]; then
        echo "- Automatic app updates are activated."
    else
        echo "- Automatic app updates are not activated."
    fi 
fi

echo -n "Hard drive encryption (FileVault) is "
filevault=$(fdesetup status 2>/dev/null)
if echo "$filevault" | grep -q "FileVault is On."; then
    echo "on."
else
    echo "off."
fi
