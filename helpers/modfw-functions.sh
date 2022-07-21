#+
# Some bash support functions for ModFW.
#-
SettingsDir=~/.modfw/$(basename $0)

function GetDefault() {
  # Parameters:
  #  1: The name of the setting.
  #  2: The default for the setting.
  if [ -e $SettingsDir/$1 ]; then
    r=`cat $SettingsDir/$1`
  else
    Verbose Setting ${e[0]} to default: ${e[1]}
    r=$2
  fi
  Verbose The setting $1 equals $r
  echo $r
}

function SetDefault() {
  # Parameters:
  #  1: The name of the setting.
  #  2: The value for the setting.
  if [ ! -d $SettingsDir ]; then
    Verbose Creating the settings directory: $SettingsDir
    mkdir -p $SettingsDir
  fi
  echo "$2">$SettingsDir/$1
  Verbose The default $1 has been set to $2
}

function ResetSetting() {
  # Parameters:
  #   1: The name of the setting.
  if [ -e $SettingsDir/$1 ]; then
    rm $SettingsDir/$1
    Verbose The setting $1 default has been set.
  else
    Verbose The setting $1 default has not been set.
  fi
}

function InitSetting() {
  # Parameters:
  #   1: The setting name and default value pair delimited by the delimeter (2)
  #   2: An optional delimeter character (defaults to '=')
  if [ -z "$2" ]; then
    d='='
  else
    d=$2
  fi
  e=(`echo "$1" | tr "$d" " "`)
  Verbose ""
  Verbose Setting default: "${e[0]} = ${e[1]}"
  eval val=\$${e[0]}
  Verbose ${e[0]} = $val
  if [ -z "$val" ]; then
    r=$(GetDefault ${e[0]} ${e[1]})
    Verbose Default was: $r
    eval ${e[0]}=$(GetDefault ${e[0]} ${e[1]})
  else
    if [ "$val" = "default" ]; then
      Verbose Setting ${e[0]} to default: ${e[1]}
      eval ${e[0]}=${e[1]}
    else
      eval ${e[0]}=$val
    fi
  fi
  eval val=\$${e[0]}
  Verbose "Setting: ${e[0]} = $val"
  Verbose "Saving setting: ${e[0]}"
  SetDefault ${e[0]} $val
}

function ClearSetting() {
  # Parameters:
  #   1: The setting name and default value pair delimited by the delimeter (2)
  #   2: An optional delimeter character (defaults to '=')
  if [ -z "$2" ]; then
    d='='
  else
    d=$2
  fi
  e=(`echo "$1" | tr "$d" " "`)
  Verbose ""
  Verbose Clearing setting: ${e[0]}
  ResetSetting ${e[0]}
}

green='\e[0;32m'
yellow='\e[0;33m'
red='\e[0;31m'
blue='\e[0;34m'
lightblue='\e[1;34m'
white='\e[1;37m'
nc='\e[0m'
id=$(basename $0)

Message () {
  echo -e "$green$id$nc: $*"
}

Tip () {
  echo -e "$green$id$nc: $white$*$nc"
}

Warning () {
  echo -e "$green$id$yellow WARNING$nc: $*"
}

Error () {
  echo >&2 -e "$green$id$red ERROR$nc: $*"
}

Verbose () {
  if [[ "$Verbose" == "y" ]]; then
      echo >&2 -e "$lightblue$id$nc: $*"
  fi
}

function Die() {
  Error "$@"
  $cleanup
  exit 1
}

function Run() {
  Verbose "Running: '$@'"
  if [[ "$DryRun" != "y" ]]; then
    "$@"; code=$?; [ $code -ne 0 ] && \
      Die "Command [$*] failed with status code $code";
  fi
  return $code
}

function RunAndIgnore {
  Verbose "Running: '$@'"
  if [[ "$DryRun" != "y" ]]; then
    "$@"; code=$?; [ $code -ne 0 ] && \
       Verbose "Command [$*] returned status code $code";
  fi
  return $code
}

function Confirm () {
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
