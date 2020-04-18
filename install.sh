#!/usr/bin/env bash

set -o errexit -o pipefail -o noclobber -o nounset
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PACKAGE_DIR="$HOME/.vim/pack/bundle/start"
#                            [^^^^] could be any name
mkdir -p "$PACKAGE_DIR"

STYLE_RESET="\x1b[0m"
STYLE_BRIGHT="\x1b[1m"
STYLE_BLUE="\x1b[34m"
STYLE_GREEN="\x1b[32m"
STYLE_RED="\x1b[41m"

info() {
  echo -e "${STYLE_BRIGHT}${STYLE_BLUE}${1}${STYLE_RESET}"
}
success() {
  echo -e "${STYLE_BRIGHT}${STYLE_GREEN}${1}${STYLE_RESET}"
}
failure() {
  echo -e "${STYLE_BRIGHT}${STYLE_RED}${1}${STYLE_RESET}"
}

vimrc_install() {
  if [[ -f ~/.vimrc ]]; then
    timestamp="$(date '+%Y-%m-%dT%H:%M:%S')"
    echo "[$(info BACKUP) ]: ~/.vimrc exists, backup to ~/.vimrc.$timestamp"
    mv ~/.vimrc ~/.vimrc."$timestamp"
  fi
  cp "$DIR/.vimrc" ~/.vimrc
  echo "[$(success FINISH) ]: installed ~/.vimrc"
}

vim_install() {
  repo="$1"
  name="$(basename $repo)"
  repo_url="https://github.com/$repo"
  repo_dir="$PACKAGE_DIR/$name"
  export GIT_TERMINAL_PROMPT=0
  set +e
  if [[ -d "$repo_dir/.git" ]]; then
    echo "[$(info UPDATE) ]: $repo"
    cd "$repo_dir"
    output=$(git pull --force 2>&1 \
      && git submodule update --init --recursive 2>&1\
      && ([[ -d "$repo_dir/doc" ]] && \
        vim -u NONE -c "helptags $repo_dir/doc" -c quit || true) 2>&1 \
      ; exit $?)
    exitcode=$?
  else
    echo "[$(info INSTALL)]: $repo"
    mkdir -p "$repo_dir"
    cd "$repo_dir"
    output=$(git clone "$repo_url" "$repo_dir" 2>&1 \
      && git submodule update --init --recursive 2>&1 \
      && ([[ -d "$repo_dir/doc" ]] && \
        vim -u NONE -c "helptags $repo_dir/doc" -c quit || true) 2>&1 \
      ; exit $?)
    exitcode=$?
  fi
  set -e
  if [[ $exitcode -eq 0 ]]; then
    echo "[$(success FINISH) ]: $repo"
  else
    echo -e "[$(failure ERROR)  ]: $repo\n$output"
  fi
}

vim_remove() {
  dir="$1"
  echo "[$(info DELETE) ]: $dir"
  rm -rf "$PACKAGE_DIR/$dir"
}

vim_setup() {
  vimrc_install

  existing="$(ls $PACKAGE_DIR)"
  packages="$@"

  for dir in $existing; do
    if [[ ! $packages =~ /$dir([[:space:]]|$) ]]; then
      vim_remove "$dir" &
    fi
  done
  wait

  for repo in $packages; do
    vim_install "$repo" &
  done
  wait

  echo "[COMPLETED VIM INSTALL]"
}

vim_setup \
  altercation/vim-colors-solarized \
  vim-airline/vim-airline \
  vim-airline/vim-airline-themes \
  preservim/nerdtree \
  jlanzarotta/bufexplorer \
  ctrlpvim/ctrlp.vim \
  shougo/deoplete.nvim \
    roxma/nvim-yarp \
    roxma/vim-hug-neovim-rpc \
  tpope/vim-surround \
  tpope/vim-repeat \
  easymotion/vim-easymotion \
  tpope/vim-abolish \
  nathanaelkane/vim-indent-guides \
  luochen1990/rainbow \
  scrooloose/syntastic \
  preservim/nerdcommenter \
  godlygeek/tabular \
  tpope/vim-fugitive \
  rhysd/conflict-marker.vim \
  mhinz/vim-signify \
  elzr/vim-json \
  pangloss/vim-javascript \
  leafgarland/typescript-vim \
  maxmellon/vim-jsx-pretty \
  jparise/vim-graphql \
  digitaltoad/vim-pug \
  vim-scripts/HTML-AutoCloseTag \
  hail2u/vim-css3-syntax \
  joukevandermaas/vim-ember-hbs \
  vim-ruby/vim-ruby \
  tpope/vim-rails \
  rhysd/vim-crystal \
  cespare/vim-toml \
  gabrielelana/vim-markdown \
  ctiml/haproxy-syntax-vim \
  '' # dummy end for consistent trailing slashes
