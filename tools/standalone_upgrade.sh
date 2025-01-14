#!/usr/bin/env bash

function _omb_upgrade {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  local ncolors=
  if type -P tput &>/dev/null; then
    ncolors=$(tput colors)
  fi

  local RED GREEN BLUE BOLD NORMAL
  if [[ -t 1 && $ncolors && $ncolors -ge 8 ]]; then
    RED=$(tput setaf 1 2>/dev/null || tput AF 1 2>/dev/null)
    GREEN=$(tput setaf 2 2>/dev/null || tput AF 2 2>/dev/null)
    BLUE=$(tput setaf 4 2>/dev/null || tput AF 4 2>/dev/null)
    BOLD=$(tput bold 2>/dev/null || tput md 2>/dev/null)
    NORMAL=$(tput sgr0 2>/dev/null || tput me 2>/dev/null)
  else
	  RED=""
	  GREEN=""
	  BLUE=""
	  BOLD=""
	  NORMAL=""
  fi

  printf '%s\n' "${BLUE}Updating Oh My Bash${NORMAL}"
  cd "$HOME"

  if curl -fsSLN https://github.com/ohmybash/oh-my-bash/archive/master.zip -o oh-my-bash-master.zip && unzip -qq oh-my-bash-master.zip && mv $HOME/oh-my-bash-master $OSH; then
    printf '%s' "$GREEN"
    # shellcheck disable=SC1003,SC2016
    printf '%s\n' \
      '         __                          __               __  ' \
      '  ____  / /_     ____ ___  __  __   / /_  ____ ______/ /_ ' \
      ' / __ \/ __ \   / __ `__ \/ / / /  / __ \/ __ `/ ___/ __ \' \
      '/ /_/ / / / /  / / / / / / /_/ /  / /_/ / /_/ (__  ) / / /' \
      '\____/_/ /_/  /_/ /_/ /_/\__, /  /_.___/\__,_/____/_/ /_/ ' \
      '                        /____/                            '
    printf "${BLUE}%s\n" "Hooray! Oh My Bash has been updated and/or is at the current version."
    printf "${BLUE}${BOLD}%s${NORMAL}\n" "To keep up on the latest news and updates, follow us on GitHub: https://github.com/ohmybash/oh-my-bash"
    exec bash; source $HOME/.bashrc
    if [[ $- == *i* ]]; then
      declare -f _omb_util_unload &>/dev/null && _omb_util_unload
      # shellcheck disable=SC1090
      source ~/.bashrc
    fi
  else
    printf "${RED}%s${NORMAL}\n" 'There was an error updating. Try again later?'
  fi
  rm ${HOME}/oh-my-bash-master.zip
}
_omb_upgrade
