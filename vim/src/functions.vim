" functions
" =====================================

" file specific autocommands
if has('autocmd')
  autocmd BufRead *tmux.conf set ft=sh
  autocmd BufRead plugins.txt set ft=sh
  autocmd BufNewFile *.sh execute "normal i#!/bin/sh\<CR>\<Esc>"
  autocmd FileType vim setlocal ts=2 sw=2 sts=2 expandtab keywordprg=:help
  autocmd FileType c{,pp} source $HOME/.vim/ftplugin/c.vim
  autocmd FileType sh source $HOME/.vim/ftplugin/sh.vim

  autocmd FileType help setlocal keywordprg=:help |
        \ silent! call ReadMode(1)
  autocmd BufNewFile main.c{,pp} execute
        \"normal oint\<Space>main()\<CR>{\<CR>\<CR>}\<Up>\<Tab>
        \return\<Space>0;\<Esc>0"
endif

function! TabFxn(tb,expd)
  execute "set tabstop=" . a:tb
  execute "set softtabstop=" . a:tb
  execute "set shiftwidth=" . a:tb
  set expandtab
  if a:expd==1
    set expandtab
    echo "expandtab"
  else
    set noexpandtab
    echo "noexpandtab"
  endif
  %retab!
endfunction

function! ReadMode(readmode_togg)
  if a:readmode_togg==1
    silent! call FlyMode(0)
    silent! set nomodifiable
    silent! set readonly
    silent! set nolist
    silent! nnoremap <buffer> q :q<CR>
    silent! nnoremap <buffer> <leader>q :q!<CR>
    silent! nnoremap <buffer> j <C-e>L0:file<CR>
    silent! nnoremap <buffer> k <C-y>L0:file<CR>
    if @% == ''
      silent! set ft=sh
      silent! nnoremap <buffer> q :q!<CR>
    endif
    let g:readmode_togg=0
    echo "Read Mode on"
  else
    silent! set modifiable
    silent! set noreadonly
    silent! nunmap <buffer> q
    silent! nunmap <buffer> <leader>q
    silent! nunmap <buffer> j
    silent! nunmap <buffer> k
    silent! execute "normal M"
    let g:readmode_togg=1
    echo "Read Mode off"
  endif
endfunction
let g:readmode_togg=1

function! FlyMode(flymode_togg)
  if a:flymode_togg==1
    silent! call ReadMode(0)
    silent! setlocal so=999
    silent! nnoremap <buffer> q :q<CR>
    let g:flymode_togg=0
    echo "Fly Mode on"
  else
    silent! setlocal so=5
    silent! nunmap <buffer> q
    let g:flymode_togg=1
    echo "Fly Mode off"
  endif
endfunction
let g:flymode_togg=1

function! PluginInstall()
  !mkdir $HOME/.vim/bundle 2>/dev/null; echo;
  \ for plugin in $(cat $HOME/.vim/plugins.txt | grep -Eo '^[^ \#]*'); do
  \   if [ -d $HOME/.vim/bundle/${plugin\#*/} ]; then
  \     cd $HOME/.vim/bundle/${plugin\#*/} && git pull --all -v;
  \   else
  \     cd $HOME/.vim/bundle && git clone https://github.com/$plugin;
  \   fi; echo;
  \ done;

  \ for dir in $(ls $HOME/.vim/bundle); do
  \   if [ \! "$(cat $HOME/.vim/plugins.txt |\
                \grep -Eo '^[^ \#]*' | grep $dir)" ]; then
  \     echo removing directory, $dir/;
  \     rm -fr $HOME/.vim/bundle/$dir;
  \   fi;
  \ done;
endfunction
command! PluginInstall silent call PluginInstall() |
      \ silent execute '!sleep 3' | redraw!
