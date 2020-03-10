#!/bin/bash

clr() {  # (number, text)
  printf "\033[38;5;${1}m${2}\033[0m"
}

__DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

FILES_TO_LINK=(
bash_profile
bashrc
inputrc
nvimrc
tmux.conf
vimrc
bin
config
vim
)

files_str="${FILES_TO_LINK[@]}"

read -r -d '' helptext << EOT
Symlinks [$(echo "${FILES_TO_LINK[@]}" | perl -pe "s/(\S+)/'\1',/g; s/.\$//s")]
in ~/.dotfiles/ (with a '.' prepended) to HOME directory.

Usage:  ~/.dotfiles/install.sh [OPTIONS]

Options:
  $(clr 3 '-h, --help')             Print this help
  $(clr 3 '-f, --vim-full')         Install all vim plugins (~100M)
  $(clr 3 '-u, --uninstall')        Uninstall maneyko's dotfiles
EOT


POSITIONAL=()
while test $# -gt 0
do
  key=$1
  case $key in
    -h|--help)
      print_help="true"
      shift  # past argument
      ;;
    -f|--vim-full)
      vim_full="true"
      shift  # past argument
      ;;
    -u|--uninstall)
      uninstall_opt="true"
      shift  # past argument
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done
set -- "${POSITIONAL[@]}"  # Restore positional parameters

if test -n "$print_help"; then
  echo "$helptext"
  exit 0
fi

for f in "${FILES_TO_LINK[@]}"; do

  fbase="$(basename "$f")"
  dotf=."${fbase}"
  home_dotf="${HOME}/${dotf}"

  if test -n "$uninstall_opt"; then
    test -L "$home_dotf" && rm -v "$home_dotf"
    continue
  fi

  if test -e "$home_dotf"; then

    printf "$home_dotf exists, move to ${__DIR__}/_backups/${dotf}? [Y/n] "
    read res

    if test -z "$res" -o "$res" = 'Y' -o "$res" = 'y'; then
      mv "$home_dotf" "${__DIR__}/_backups/"
    else
      continue
    fi

    ln -vs "${__DIR__}/${fbase}" "$home_dotf"
  fi
done

vim_path="$(type -P nvim vim vi | head -1)"
vim="$(basename $vim_path)"

if test "$vim" = 'nvim'; then
  curl -fLo $HOME/.local/share/nvim/site/autoload/plug.vim \
    --create-dirs \
      'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if test -z "$vim_full"; then
    perl -i -pe 's/minimal_vimrc = ([\d]+)/minimal_vimrc = 1/g' $HOME/.nvimrc
  else
    python3 -m pip install pynvim --upgrade
  fi
else
  curl -fLo $HOME/.vim/autoload/plug.vim \
    --create-dirs \
    'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if test -z "$vim_full"; then
    perl -i -pe 's/minimal_vimrc = ([\d]+)/minimal_vimrc = 1/g' $HOME/.vimrc
  fi
fi

$vim +PlugInstall +qall

if test "$vim" = 'nvim'; then
  $vim +UpdateRemotePlugins +qall
  rm ~/.config/nvim/plugged/vim-plug/.git/objects/pack/*.pack
else
  rm ~/.vim/plugged/vim-plug/.git/objects/pack/*.pack
fi