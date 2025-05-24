#!/usr/bin/env zsh

# Global variables
bold="$(tput bold)"
normal="$(tput sgr0)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
yellow="$(tput setaf 3)"
blue="$(tput setaf 4)"
magenta="$(tput setaf 5)"

# Functions

get_dns_servers() {
  # Using global variables for bold and normal
  networksetup -listallnetworkservices | sed '1d' | while read -r service; do
    info=$(networksetup -getinfo "$service")
    if echo "$info" | grep -q "IP address: [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+"; then
      if networksetup -getnetworkserviceenabled "$service" | grep -q "Enabled"; then
        ip_address=$(echo "$info" | awk '/^IP address:/{print $NF}')
        dns_servers=$(networksetup -getdnsservers "$service")
        if [[ "$dns_servers" == "There aren't any DNS Servers set"* ]]; then
          dns_servers="N/A"
        else
          dns_servers=$(echo "$dns_servers" | tr '\n' ',' | sed 's/,$//')
        fi
        echo "${bold}Service:${normal} $service ${bold}IP Address:${normal} $ip_address ${bold}DNS Servers:${normal} $dns_servers"
      fi
    fi
  done
}

refresh_network() {
  # Using global variables for bold and normal
  clear_dns="${1:-}"

  # Argument validation
  if [[ -n "$clear_dns" && "$clear_dns" != "clear_dns" ]]; then
    echo "${bold}Error:${normal} Invalid argument: '$clear_dns'"
    echo "Usage: refresh_network [clear_dns]"
    return 1
  fi

  networksetup -listallnetworkservices | sed '1d' | while read -r service; do
    info=$(networksetup -getinfo "$service")
    # echo "$info"
    if echo "$info" | grep -q "IP address: [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+" && \
       # echo "$service"
       networksetup -getnetworkserviceenabled "$service" | grep -q "Enabled"; then
      if [ "$clear_dns" = "clear_dns" ]; then
        echo "${bold}Clearing DNS....${normal}"
        networksetup -setdnsservers "$service" empty
        echo "${bold}Network Service:${normal} $service, ${bold}DNS Servers:${normal} Cleared"
      else
        echo "${bold}Restarting....${normal}"
        networksetup -setnetworkserviceenabled "$service" off
        networksetup -setnetworkserviceenabled "$service" on
        echo "${bold}Network Service:${normal} $service ${bold}Status:${normal} Restarted"
      fi
    fi
  done
  echo "${bold}DNS Refresh Status:${normal} Done"
  sudo killall -HUP mDNSResponder
  sudo dscacheutil -flushcache
}

xping() {
  ping "$1" | while read pong; do
    echo "$(TZ=UTC date '+%b %d %H:%M:%S %Z') $pong"
  done
}

get_ips_egypt() {
  public_ip_we=$(curl -s -u 787ea028-6bb5-4ade-d2db-53585e02d6ce:x -X GET https://www.getflix.com.au/api/v1/addresses.json | jq --raw-output '.[0].ip_address')
  public_ip_og=$(curl -s -u dc075e55-726d-43e9-f251-faadb9c3a27d:x -X GET https://www.getflix.com.au/api/v1/addresses.json | jq --raw-output '.[0].ip_address')
  printf "%-25s %-10s %-15s\n" "Hardware Port" "Device" "IP Address"
  printf "%-25s %-10s %-15s\n" "-------------" "------" "----------"
  if [[ -n "$public_ip_we" ]]; then
    printf "%-25s %-10s %-15s\n" "Public IP WE" "-" "${bold}$public_ip_we ${normal}"
  fi
  if [[ -n "$public_ip_og" ]]; then
    printf "%-25s %-10s %-15s\n" "Public IP Orange" "-" "${bold}$public_ip_og ${normal}"
  fi
}

get_ips() {
  printf "%-25s %-10s %-15s\n" "Hardware Port" "Device" "IP Address"
  printf "%-25s %-10s %-15s\n" "-------------" "------" "----------"

  # Local interfaces
  networksetup -listallhardwareports | awk '
    /^Hardware Port/ {port=$3; for(i=4;i<=NF;i++) port=port " " $i}
    /^Device/ {dev=$2; print port "|" dev}
  ' | while IFS="|" read -r port dev; do
    ip=$(ipconfig getifaddr "$dev" 2>/dev/null)
    [[ -n "$ip" ]] && printf "%-25s %-10s %-15s\n" "$port" "$dev" "$ip"
  done

  # VPN interfaces
  for dev in $(ifconfig -l); do
    case "$dev" in
      utun*|tun*|tap*)
        ip=$(ipconfig getifaddr "$dev" 2>/dev/null)
        [[ -z "$ip" ]] && ip=$(ifconfig "$dev" 2>/dev/null | awk '/inet / {print $2; exit}')
        [[ -z "$ip" ]] && ip=$(ifconfig "$dev" 2>/dev/null | awk '/inet6 / && !/fe80/ {print $2; exit}')
        [[ -n "$ip" ]] && printf "%-25s %-10s %-15s\n" "VPN Interface" "$dev" "${bold}$ip ${normal}"
        ;;
    esac
  done

  # Public IP
  public_ip=$(curl -s --max-time 2 checkip.amazonaws.com)
  [[ -n "$public_ip" ]] && printf "%-25s %-10s %-15s\n" "Public IP" "-" "${bold}$public_ip ${normal}"
}

get_cpu_temp() {
  local cpu_temp=-1
  if command -v osx-cpu-temp >/dev/null 2>&1; then
    cpu_temp="${$(osx-cpu-temp)%%°*}"
  elif command -v vcgencmd >/dev/null 2>&1; then
    cpu_temp="${$(vcgencmd measure_temp)%%°*}"
  elif [ -d /sys/class/thermal/thermal_zone0 ]; then
    cpu_temp="$(($(</sys/class/thermal/thermal_zone0/temp) / 1000))"
  fi
  echo "$cpu_temp"
}

notify() {
  app=$(hostname -s)
  event="$*"
  url="https://api.prowlapp.com/publicapi/add"
  [ -z "$event" ] && event="Done!"
  response=$(curl -s "$url" \
    --data apikey="$PROWL_MAC_API_KEY" \
    --data-urlencode application="$app" \
    --data-urlencode event="$event")
  if grep -q 'code="200"' <<< "$response"; then
    echo "Notified: $event"
  else
    echo "Error:"
    echo "$response"
  fi
}

get_file_type() {
  mdls -name kMDItemContentType -name kMDItemContentTypeTree -name kMDItemKind "$@"
}


