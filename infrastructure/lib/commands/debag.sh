#!/usr/bin/env bash

set -e

debag_action(){
  
  print_version

  #Show operating system version
  gum_style "$COLOR_PRIMARY" "Operating System Version:"
  case "$(uname -s)" in
      Linux*)     cat /etc/os-release;;
      Darwin*)    sw_vers;;
      *)          echo "This operating system is not supported." && exit 2
  esac
  printf "\n"
  
  #Show docker version
  gum_style "$COLOR_PRIMARY" "Docker Info:"
  gum style \
	--foreground 212 --border-foreground 212 --border double \
	--align left --width 100 --margin "1 2" --padding "2 4" \
	"$(docker info)"

}
