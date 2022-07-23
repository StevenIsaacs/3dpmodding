#+
# Some bash support functions for ModFW.
#-
id=$(basename $0)
SettingsDir=~/.modfw/$(basename $0)

function get_default() {
  # Parameters:
  #  1: The name of the setting.
  #  2: The default for the setting.
  if [ -e $SettingsDir/$1 ]; then
    r=`cat $SettingsDir/$1`
  else
    verbose Setting ${e[0]} to default: ${e[1]}
    r=$2
  fi
  verbose The setting $1 equals $r
  echo $r
}

function set_default() {
  # Parameters:
  #  1: The name of the setting.
  #  2: The value for the setting.
  if [ ! -d $SettingsDir ]; then
    verbose Creating the settings directory: $SettingsDir
    mkdir -p $SettingsDir
  fi
  echo "$2">$SettingsDir/$1
  verbose The default $1 has been set to $2
}

function reset_setting() {
  # Parameters:
  #   1: The name of the setting.
  if [ -e $SettingsDir/$1 ]; then
    rm $SettingsDir/$1
    verbose The setting $1 default has been set.
  else
    verbose The setting $1 default has not been set.
  fi
}

function init_setting() {
  # Parameters:
  #   1: The setting name and default value pair delimited by the delimeter (2)
  #   2: An optional delimeter character (defaults to '=')
  if [ -z "$2" ]; then
    d='='
  else
    d=$2
  fi
  e=(`echo "$1" | tr "$d" " "`)
  verbose ""
  verbose Setting default: "${e[0]} = ${e[1]}"
  eval val=\$${e[0]}
  verbose ${e[0]} = $val
  if [ -z "$val" ]; then
    r=$(get_default ${e[0]} ${e[1]})
    verbose Default was: $r
    eval ${e[0]}=$(get_default ${e[0]} ${e[1]})
  else
    if [ "$val" = "default" ]; then
      verbose Setting ${e[0]} to default: ${e[1]}
      eval ${e[0]}=${e[1]}
    else
      eval ${e[0]}=$val
    fi
  fi
  eval val=\$${e[0]}
  verbose "Setting: ${e[0]} = $val"
  verbose "Saving setting: ${e[0]}"
  set_default ${e[0]} $val
}

function clear_setting() {
  # Parameters:
  #   1: The setting name and default value pair delimited by the delimeter (2)
  #   2: An optional delimeter character (defaults to '=')
  if [ -z "$2" ]; then
    d='='
  else
    d=$2
  fi
  e=(`echo "$1" | tr "$d" " "`)
  verbose ""
  verbose Clearing setting: ${e[0]}
  reset_setting ${e[0]}
}

green='\e[0;32m'
yellow='\e[0;33m'
red='\e[0;31m'
blue='\e[0;34m'
lightblue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'

message () {
  echo -e "$green$id$nc: $*"
}

tip () {
  echo -e "$green$id$nc: $white$*$nc"
}

warning () {
  echo -e "$green$id$yellow WARNING$nc: $*"
}

error () {
  echo >&2 -e "$green$id$red ERROR$nc: $*"
}

verbose () {
  if [[ "$Verbose" == "y" ]]; then
      echo >&2 -e "$lightblue$id$nc: $*"
  fi
}

function die() {
  error "$@"
  $cleanup
  exit 1
}

function run() {
  verbose "Running: '$@'"
  if [[ "$DryRun" != "y" ]]; then
    "$@"; code=$?; [ $code -ne 0 ] && \
      die "Command [$*] failed with status code $code";
  fi
  return $code
}

function run_and_ignore {
  verbose "Running: '$@'"
  if [[ "$DryRun" != "y" ]]; then
    "$@"; code=$?; [ $code -ne 0 ] && \
       verbose "Command [$*] returned status code $code";
  fi
  return $code
}

function confirm () {
  read -r -p "${1:-Are you sure? [y/N]} " response
  case $response in
    [yY][eE][sS]|[yY])
      true
      ;;
    *)
      false
      ;;
  esac
}
