#!/usr/bin/env sh
########################################################
# This script allows you to send push notifications mobile
# It uses https://www.prowlapp.com service
# Expects api key token at ~/.keys/.prowl
# Author: Mourad Askar
########################################################

api_key_file=$HOME/.keys/.prowl

# If key file doesn't exists exit with error message
[ ! -f "$api_key_file" ] && { echo "$api_key_file is missing"; exit 1; }
# Read API key token
read -r key < "$api_key_file"
# Set hostname as the notification title
app=$(hostname -s)
# Use all parameters as the text for the notification message
event=$@
# API service URL
url="https://api.prowlapp.com/publicapi/add"

# If no parameters supplied, then set default notification message as "Done!"
[ "$event" = "" ] && event="Done!"

# Submit api request
response=$(curl $url \
	--data apikey=$key \
	--data-urlencode application="$app" \
	--data-urlencode event="$event" \
	-s \
	) 

# If request succeed print out feedback as Notified: and event
if grep -q 'code="200"' <<< "$response"; then
  	echo "Notified: $event"
  else
	# If request fails print out the response
	echo "Error:"
	echo $response
fi