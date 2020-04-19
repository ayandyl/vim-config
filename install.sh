#!/usr/bin/env bash

set -o errexit -o pipefail -o noclobber -o nounset
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

vim_config() {
  config_dir=~/.config/nvim
  config_file="$config_dir/init.vim"
  mkdir -p "$config_dir"
  if [[ -f $config_file ]]; then
    timestamp="$(date '+%Y-%m-%dT%H:%M:%S')"
    echo "[CONFIG]: $config_file exists, backup to $config_file.$timestamp"
    mv "$config_file" "$config_file.$timestamp"
  fi
  echo "[CONFIG]: install $config_file"
  cp "$DIR/init.vim" "$config_file"
}

vim_plugin() {
  vimplug=~/.local/share/nvim/site/autoload/plug.vim
  if [[ ! -f $vimplug ]]; then
    echo "[VIM-PLUG]: download vim-plug itself"
    curl -fLo "$vimplug" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  echo "[VIM-PLUG]: install/update plugins"
  nvim -u ~/.config/nvim/init.vim -i NONE -c 'PlugUpdate' -c 'qa'
}

vim_install() {
  vim_config
  vim_plugin
  echo "[COMPLETED]"
}

vim_install
