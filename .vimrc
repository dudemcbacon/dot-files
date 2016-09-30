" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

if has('vim_starting')
 set nocompatible               " Be iMproved

 " Required:
 set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle/'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" My NeoBundles
NeoBundle 'CmdlineComplete'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'Valloric/YouCompleteMe'
NeoBundle 'bling/vim-airline'
NeoBundle 'bronson/vim-trailing-whitespace'
NeoBundle 'elzr/vim-json'
NeoBundle 'fatih/vim-go'
NeoBundle 'godlygeek/tabular'
NeoBundle 'puppetlabs/puppet-syntax-vim'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'tpope/vim-sensible'
NeoBundle 'tpope/vim-surround'
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'puppetlabs/puppet-syntax-vim'
NeoBundle 'tpope/vim-endwise'

NeoBundleFetch 'Shougo/neobundle.vim'
call neobundle#end()

filetype plugin indent on

NeoBundleCheck

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

" Recommended Syntastic Settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_eruby_ruby_quiet_messages =
    \ {'regex': 'possibly useless use of a variable in void context'}
