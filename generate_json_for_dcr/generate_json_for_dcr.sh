#!/bin/bash

################################################################################
#
# Author: dcodev1702
# Date: 02.17.2023
# Purpose: Basic shell script to:
#  -- Check if Logstash is installed on system
#  -- Check if Microsoft Logstash Sentinel DCR Output Plugin is installed
#     + If not found, the output plugin will be installed
#  -- Setup necessary directories -> /tmp/logstash
#  -- Copy STD|JSON logstash pipeline conf to /etc/logstash/conf.d/
#  -- Run logstash command to convert unstructured log entry to JSON
#     format so DCR transformation can take place
#  -- Remove STDIN/JSON logstash pipeline file from /etc/logstash/conf.d/
#  -- Display (cat) Logstash Sentinel DCR files in JSON
#
###############################################################################

logstash_dir="/tmp/logstash"
logstash_json_conf="stdin-dcr-sentinel-sample.conf"
logstash_binary="/usr/share/logstash/bin/logstash"


echo -e "\033[33m\nValidating Logstash is installed on this system..\033[0m"
# Test if logstash is installed on the system.
if command -v "$logstash_binary" &> /dev/null; then
  echo -e "$logstash_binary is present (installed) on the system..\n"
else
  echo -e "$logstash_binary is not present, you must install logstash before continuing..\n"
  exit 1
fi


echo -e "\033[33mChecking Logstash for Microsoft Logstash Sentinel DCR Output Plugin\033[0m"

logstash_sentinel_output_plugin=$(sudo /usr/share/logstash/bin/logstash-plugin list microsoft-sentinel-logstash-output-plugin)
# Check if the microsoft-sentinel-logstash plugin is installed, if not, install it
if [[ $logstash_sentinel_output_plugin =~ "microsoft-sentinel-logstash-output-plugin" ]]; then
  echo -e "$logstash_sentinel_output_plugin :: logstash plugin is installed!\n"
else
  echo -e "The plugin [$logstash_sentinel_output_plugin] is not installed, installing plugin, now."
  sudo /usr/share/logstash/bin/logstash-plugin install microsoft-sentinel-logstash-output-plugin > /dev/null 2>&1
fi


# Do we already have a logstash directory in /tmp?
if [ -d "$logstash_dir" ]; then
   echo -e "logstash directory already exists in /tmp\n"
else
   mkdir -p -v "$logstash_dir"
   echo -e "\033[33mlogstash directory successfully created in /tmp\033[0m\n"
fi


# Ensure the logstash json pipeline config exists before copying to /etc/logstash/conf.d/
if [ -f "$logstash_json_conf" ] && [[ ! $(readlink -f "$logstash_json_conf") =~ /etc/logstash/conf\.d/* ]]; then
   echo -e "\033[33mCopying STDIN logstash pipeline config to \"/etc/logstash/config.d/\"...\033[0m"
   sudo cp -v "./$logstash_json_conf" /etc/logstash/conf.d/
else
   echo -e "\031[31m$logstash_json_conf file not found!\031[0m"
   echo -e "\031[31mSorry, we cannot proceed, please go here to fix!\031[0m"
fi

# This command generates the JSON output from an Apache2 Log entry and stores the file in /tmp/logstash
echo -e "\e[32m\nGenerating Apache2 Log entry in JSON format for Data Collection Rule (DCR) Transformation\e[0m"
cat apache2_accesslog_entry.txt | sudo /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/$logstash_json_conf > /dev/null 2>&1

echo -e "\033[33mGo to $logstash_dir and your sample JSON file should be there.\033[0m"
echo -e "\033[33mUpload this JSON file to DCR Transformation Editor in order to normalize the apache2 log entry for Log Analytics.\033[0m\n"

echo -e "\033[33mDeleting logstash STDIN -> JSON pipeline config from /etc/logstash/conf.d/ \033[0m"
sudo rm -fv /etc/logstash/conf.d/$logstash_json_conf


# Define the path to the directory containing the files
JSONFileDirectory="/tmp/logstash"

# Loop over the files in the directory
for file in "$JSONFileDirectory"/*
do
  # Check if the file is a regular file (not a directory or a symlink)
  if [ -f "$file" ]; then

    # Print the name of the file
    echo -e "\e[32m\nFile: $file\e[0m"

    # Output the contents of the file
    cat "$file"; echo

  fi
done
