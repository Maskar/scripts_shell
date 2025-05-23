#!/usr/bin/env zsh

#sudo sh -c 'echo "%admin ALL=(ALL) NOPASSWD: /usr/local/bin/openconnect" > /etc/sudoers.d/foo'

#
# ZSH functions to start/stop OpenConnect VPN client
#
# In my setup the VPN username is the same as $USER
#

export VPN_CONFIG_PATH=${XDG_CONFIG_HOME}/tfxcorp
export VPN_HOST=$(< ${VPN_CONFIG_PATH}/vpnh)
export VPN_HOST_CERT=$(< ${VPN_CONFIG_PATH}/vpnhc)
export VPN_GROUP=$(< ${VPN_CONFIG_PATH}/vpng)

COLOR_MACROS_FILE=${ZDOTDIR}/color_macros
[ -f "$COLOR_MACROS_FILE" ] && source "$COLOR_MACROS_FILE" || { echo -e "${BLINK}${BIYellow}${COLOR_MACROS_FILE} is required.${Color_Off}"; return; }

for cmd in op openconnect sudo; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "${BIRed}$cmd is required but not installed.${Color_Off}"; return 1; }
done

# Allow OP_ACCOUNT to be set externally, fallback to hardcoded value
: "${OP_ACCOUNT:=E44VP6N4VRGWZKIFB3XAAQTTEA}"

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Usage: vpn-up [VPN_HOST] [VPN_HOST_CERT]"
  echo "  VPN_HOST:      Override the VPN host (optional)"
  echo "  VPN_HOST_CERT: Override the VPN host certificate (optional)"
  echo ""
  echo "This script signs in to 1Password, fetches VPN credentials, and starts OpenConnect VPN."
  return 0
fi

function start_openconnect() {
  local oc_opts="$1"
  local redirect="$2"
  local password group username cert
  if [[ -z "$VPN_HOST" ]]; then
    echo "${BIYellow}VPN_HOST is not set. Aborting.${Color_Off}"
    return 1
  fi
  if [[ -z "$VPN_GROUP" ]]; then
    echo "${BIYellow}VPN_GROUP is not set. Aborting.${Color_Off}"
    return 1
  fi
  password=$(op read "op://TM/TFX VPN/password" 2>/dev/null)
  group=$(op read "op://TM/TFX VPN/group" 2>/dev/null)
  username=$(op read "op://TM/TFX VPN/username" 2>/dev/null)
  cert=$(op read "op://TM/TFX VPN/cert" 2>/dev/null)
  if [[ -z "$password" || -z "$group" || -z "$username" ]]; then
    echo "${BIRed}Failed to fetch VPN credentials from 1Password. Aborting.${Color_Off}"
    return 1
  fi
  local cmd=(sudo openconnect $oc_opts --disable-ipv6 --passwd-on-stdin --authgroup="$group" --user="$username")
  if [[ -n "$VPN_HOST_CERT" ]]; then
    cmd+=(--servercert "$VPN_HOST_CERT")
  fi
  cmd+=("$VPN_HOST")

  if [[ "$redirect" == "true" ]]; then
    echo "$password" | "${cmd[@]}" &> /dev/null
  else
    echo "$password" | "${cmd[@]}"
  fi
}

function vpn-up() {
  op signin --account "$OP_ACCOUNT"
  if [[ $? -ne 0 ]]; then
    echo "${BIRed}1Password signin failed. Aborting.${Color_Off}"
    return 1
  fi

  if [[ -n "$1" ]]; then
    export VPN_HOST="$1"
  elif [[ -n $(op read "op://TM/TFX VPN/host" 2>/dev/null) ]]; then
    export VPN_HOST="$(op read "op://TM/TFX VPN/host" 2>/dev/null)"
  else
    echo "${BIYellow}Please set VPN_HOST env var${Color_Off}"
    return 1
  fi

  if [[ -n "$2" ]]; then
    export VPN_HOST_CERT="$2"
    echo "${BIYellow}Using VPN_HOST_CERT${Color_Off}"
  else
    export VPN_HOST_CERT=
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
