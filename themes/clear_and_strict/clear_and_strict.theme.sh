#!/usr/bin/env sh

function prompt_command() {

  # Adresse IP de la première interface non-loopback (hors lo, sans le /prefix)
  HOST_IP=$(ip -o -4 addr show scope global up 2>/dev/null | awk '$2 != "lo" {print $4; exit}' | cut -d'/' -f1)
  PS1=""

  if [ $(id -u) -eq 0 ]
  then
    # you are root
    PS1="\n${background_red}[\D{%F %T}]-[\u @ \h (${HOST_IP})]-[${PWD}]${normal}\n# "
  else
    # you are regular user
    PS1="\n[${cyan}\D{%F %T}${reset_color}]-[${green}\u @ \h (${HOST_IP})${reset_color}]-[${purple}${PWD}${reset_color}]\n$ "
  fi

}

safe_append_prompt_command prompt_command
