#!/usr/bin/env zsh

#sudo sh -c 'echo "%admin ALL=(ALL) NOPASSWD: /usr/local/bin/openconnect" > /etc/sudoers.d/foo'

#
# ZSH functions to start/stop OpenConnect VPN client
#
# In my setup the VPN username is the same as $USER
#

COLOR_MACROS_FILE=${ZDOTDIR}/color_macros
[ -f "$COLOR_MACROS_FILE" ] && source "$COLOR_MACROS_FILE" || { echo -e "${BLINK}${BIYellow}${COLOR_MACROS_FILE} is required.${Color_Off}"; return; }

for cmd in op openconnect sudo; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "${BIRed}$cmd is required but not installed.${Color_Off}"; return 1; }
done



if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: vpn-up [VPN_HOST] [VPN_CERTIFICATE]"
  echo "  VPN_HOST:        Override the VPN host (optional)"
  echo "  VPN_CERTIFICATE: Override the VPN server certificate (optional)"
  echo ""
  echo "Starts an OpenConnect VPN session using credentials provided via environment variables."
  return 0
fi

function start_openconnect() {
  local oc_opts="$1"
  local redirect="$2"
  local password group username cert

  source "${XDG_CONFIG_HOME}/vpn_env.zsh"

  if [[ -z "$VPN_HOST" ]]; then
    echo "${BIYellow}VPN_HOST is not set. Aborting.${Color_Off}"
    return 1
  fi
  if [[ -z "$VPN_GROUP" ]]; then
    echo "${BIYellow}VPN_GROUP is not set. Aborting.${Color_Off}"
    return 1
  fi

  # Expect credentials to be supplied via environment variables    
  local op_account="${OP_ACCOUNT:-}"
  local password="${VPN_PASSWORD:-}"
  local group="${VPN_GROUP:-}"
  local username="${VPN_USERNAME:-}"
  local cert="${VPN_CERTIFICATE:-}"

  if [[ -z "$password" || -z "$group" || -z "$username" ]]; then
    echo "${BIRed}VPN credentials not found in environment variables. Aborting.${Color_Off}"
    return 1
  fi
  local cmd=(sudo openconnect $oc_opts --disable-ipv6 --passwd-on-stdin --authgroup="$group" --user="$username")
    if [[ -n "$cert" ]]; then
    cmd+=(--servercert "$cert")
  fi
  cmd+=("$VPN_HOST")

  if [[ "$redirect" == "true" ]]; then
    echo "$password" | "${cmd[@]}" &> /dev/null
  else
    echo "$password" | "${cmd[@]}"
  fi
  unset password  # wipe credentials from memory
}

function vpn-up() {


  if [[ -n "$1" ]]; then
    export VPN_HOST="$1"
  elif [[ -z "${VPN_HOST:-}" ]]; then
    echo "${BIYellow}VPN_HOST environment variable is not set${Color_Off}"
    return 1
  fi

  if [[ -n "$2" ]]; then
    export VPN_CERTIFICATE="$2"
    echo "${BIYellow}Using VPN_CERTIFICATE${Color_Off}"
  fi

  if pgrep -x "openconnect" > /dev/null; then
    echo "${CHECK_MARK}${BICyan}VPN is already running!${Color_Off}"
    return
  else
    echo "${BICyan}Starting the VPN ...${Color_Off}"
    echo "${BLINK}${BIYellow}Approve connection on phone!${Color_Off}"
    start_openconnect "-bq" true
  fi

  if pgrep -x "openconnect" > /dev/null; then
    echo "${REPLACE_2LINE}${CHECK_MARK} VPN started to ${VPN_HOST}!${Color_Off}"
  else
    echo "${REPLACE_2LINE}${EXCLAMATION_MARK} ${BIRed}VPN failed to start!${Color_Off}"
    echo "${BICyan}Retrying in debug mode (not quiet)...${Color_Off}"
    start_openconnect "-bv" false
  fi
}

function vpn-down() {
  if pgrep -x "openconnect" > /dev/null
  then
    echo "${BIRed}Killing the VPN ...${Color_Off}"
    sleep 1
    sudo kill -2 `pgrep openconnect` &> /dev/null
    echo "${REPLACE_LINE}${CHECK_MARK} VPN killed!${Color_Off}"
else
    echo "${EXCLAMATION_MARK}${BICyan}VPN is already not running!${Color_Off}"
    return
  fi
}

# vpn-up "$@"
