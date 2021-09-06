#!/usr/bin/env sh

version="0.0.1"

# locate airport(1) on macOS
airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport"

if [ "$verbose" ]; then
  echo "airport: $airport"
fi

if [ ! -f $airport ]; then
  echo "Error: can't find \`airport\` CLI program at \"$airport\""
  exit 1
fi

# verbose by default(unless non-tty)
if [ -t 1 ]; then
    verbose=1
else
    verbose=
fi

if [ "$verbose" ]; then
  echo "verbose: $verbose"
fi

# how to use

usage() {
  cat <<EOF
  Usage: wifi-pwd [options] [ssid]
  Options:
    -q, --quiet       Only output the password
    -v, --version     Output version
    -h, --help        This message
    --                End of options
EOF
}

# how to parse usage message

while [[ "$1" =~ ^- && ! "$1" = "--" ]]; do
  case $1 in
  -v | --version)
    echo $version
    exit
    ;;
  -q | --quite)
  verbose=
  ;;
  -h | --help)
  usage
  exit
  ;;
  esac
  shift
done
if [ "$1" = "--" ]; then shift; fi

# how to merge args for SSIDs with space

args="$@"

if [ "$verbose" ]; then
  echo "args: $args"
fi

# check user-provided ssid

if [ "" != "$args" ]; then
    ssid="$@"
else
  # obtain ssid
  ssid="$($airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}')"
  if [ "$ssid" = "" ]; then
      echo "Error: could not retrieve current ssid. Are you wifi-connected?" >&2
      exit 1
  fi
fi

if [ "$verbose" ]; then
  echo "ssid: $ssid"
fi

# warn user about keychain dialog
if [ "$verbose" ]; then
    echo "\033[90m ... getting password for \"$ssid\". \033[39m"
    echo "\033[90m ... keychain prompt incoming. \033[39m"
fi

sleep 2

# how to access keychain
# from: http://blog.macromates.com/2006/keychain-access-from-shell/
password="$(security find-generic-password -D 'AirPort network password' -ga \"$ssid\" 2>&1 >/dev/null)"

if [ "$verbose" ]; then
  echo "password: $password"
fi

if [[ "$password" =~ "could" ]]; then
    echo "Error: could not find SSID \"$ssid\"" >&2
    exit 1
fi

# clear password
password=$(echo "$password" | sed -e "s/^.*\"\(.*\)\".*$/\1/")

if [ "$verbose" ]; then
  echo "password: $password"
fi

if [ "" = "$password" ]; then
    echo "Error: could not get password. Did you store your keychain credentials?" >&2
    exit 1
fi

# display in command line console
if [ "$verbose" ]; then
    echo "\033[96m ✓ \"$password\" \033[39m"
    echo ""
else
  echo "$password"
fi