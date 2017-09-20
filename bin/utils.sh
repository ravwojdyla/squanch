#!/bin/bash

function print_color {
  local msg=${1?}
  local kind=${2:-GREEN}
  case "$kind" in
    RED)
      echo -e "$(tput setaf 1) $msg $(tput setaf 7)" >&2 ;;
    *)
      echo -e "$(tput setaf 2) $msg $(tput setaf 7)" ;;
  esac
}

function fatal_error {
  local msg=${1?"log message for fatal error not set"}
  print_color "$msg" RED
  exit 1
}
