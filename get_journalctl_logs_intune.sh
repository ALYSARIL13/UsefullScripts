#!/bin/bash

#Coloring:
SUBTITLE='\033[0;97m'
INFO='\033[0;92m'
TITLE='\033[1;93m'
RESET='\033[0m'
WARNING='\033[0;91m' 

#TEMP path for logs:
logsPath="$HOME/.cache/Microsoft/Identity/Broker/Logs"
mkdir -p $logsPath

#Script Execution
printf "${TITLE}Collecting & Merging Logs...\n"
printf "${SUBTITLE} 1. Collecting System Broker Device Logs... ${WARNING}(requires elevation to collect logs from a System Service)\n"
sudo journalctl --system -b | grep -i 'microsoft-identity-device-broker' > $logsPath/broker.log
printf "${INFO}	Done!\n"

printf "${SUBTITLE} 2. Collecting User Broker Logs..."
journalctl --user -b | grep -i 'microsoft-identity-broker' > $logsPath/user.log
printf "${INFO} Done!\n"

printf "${SUBTITLE} 3. Collecting Intune Portal app logs..."
journalctl --user -b | grep -i 'intune-agent' > $logsPath/intune_agent.log
journalctl --user -b | grep -i 'intune-portal' > $logsPath/intune_portal.log
printf "${INFO} Done!\n"

printf "${SUBTITLE} 4. Collecting Journal logs for Microsoft Edge..."
journalctl --user -b | grep -i 'microsoft-edge' > $logsPath/microsoft_edge.log
printf "${INFO} Done!\n"

printf "${SUBTITLE} 5. Collecting package details for Microsoft Identity Broker, Microsoft Edge, Intune Portal..."
touch installed_apps.txt
apt show intune-portal >> $logsPath/installed_apps.txt 2>&1
apt show microsoft-edge-stable >> $logsPath/installed_apps.txt 2>&1
apt show microsoft-identity-broker >> $logsPath/installed_apps.txt 2>&1
printf "${INFO} Done!\n"

printf "${SUBTITLE} 6. Zipping files, please wait... "
fileName="$(hostname)_$(date "+%Y-%m-%dT%H.%M.%S").zip"
zip -q $HOME/Desktop/$fileName $logsPath/*
printf "${INFO} Done! The output file can be located at $HOME/Desktop/$fileName\n"

printf "${SUBTITLE} 7. Cleanning up resources..."
rm -r $logsPath/*
printf "${INFO} Done!\n"

printf "${TITLE}Tool execution completed!\n"
