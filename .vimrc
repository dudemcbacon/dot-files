" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

"dein Scripts-----------------------------
if &compatible
  set nocompatible               " Be iMproved
endif

" Required:
set runtimepath+=~/.cache/dein/repos/github.com/Shougo/dein.vim

" Required:
if dein#load_state('~/.cache/dein')
  call dein#begin('~/.cache/dein')

  " Let dein manage dein
  " Required:
  call dein#add('~/.cache/dein/repos/github.com/Shougo/dein.vim')

  call dein#add('Raimondi/delimitMate')
  call dein#add('bronson/vim-trailing-whitespace')
  call dein#add('christoomey/vim-tmux-navigator')
  call dein#add('elzr/vim-json')
  call dein#add('fatih/vim-go')
  call dein#add('godlygeek/tabular')
  call dein#add('hashivim/vim-terraform')
  call dein#add('mtscout6/syntastic-local-eslint.vim')
  call dein#add('puppetlabs/puppet-syntax-vim')
  call dein#add('scrooloose/syntastic')
  call dein#add('tpope/vim-endwise')
  call dein#add('tpope/vim-fugitive')
  call dein#add('tpope/vim-sensible')
  call dein#add('tpope/vim-surround')
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('vim-ruby/vim-ruby')
  call dein#add('vim-scripts/CmdlineComplete')

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on

set background=dark
colorscheme solarized

set autoindent
set tabstop=2
set shiftwidth=2
set expandtab

set number
set mouse=a

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

set wildmode=longest,list,full
set wildmenu

syntax on

" jk is escape
inoremap jk <esc>
inoremap <esc> <nop>

" vim-airline options
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_solarized_bg='dark'

" Recommended Syntastic Settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_go_checkers = ['go', 'gofmt', 'govet']
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_eruby_ruby_quiet_messages =
    \ {'regex': 'possibly useless use of a variable in void context'}
let g:syntastic_javascript_checkers = ['eslint']

" Easier Split Navigation
" We can use different key mappings for easy navigation between splits to save
" a keystroke. So instead of ctrl-w then j, it’s just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Fixes extra characters being pasted into VIM on macOS
" https://stackoverflow.com/questions/44848979/getting-strange-characters-when-pasting-into-my-iterm2-terminal
set t_BE=

" Some vim-terraform config
let g:terraform_align=1
let g:terraform_fmt_on_save=1
