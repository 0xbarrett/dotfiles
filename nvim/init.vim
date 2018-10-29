if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=/Users/barrettbrown/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('/Users/barrettbrown/.cache/dein')
  call dein#begin('/Users/barrettbrown/.cache/dein')

  " Let dein manage dein
  " Required:
  call dein#add('/Users/barrettbrown/.cache/dein/repos/github.com/Shougo/dein.vim')

  " Add or remove your plugins here like this:
  "call dein#add('Shougo/neosnippet.vim')
  "call dein#add('Shougo/neosnippet-snippets')
  call dein#add('wsdjeg/dein-ui.vim')

  " Required:
  call dein#end()
  call dein#save_state()
endif

" Required:
filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif
