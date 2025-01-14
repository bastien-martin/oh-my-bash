#!/usr/bin/env sh

function prompt_command() {

  HOST_IP=$(ifconfig | grep 'inet '| grep -v '127.0.0.1' | xargs | cut -d' ' -f2)
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
