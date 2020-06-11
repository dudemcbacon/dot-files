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

  call dein#add('tpope/vim-vinegar')
  call dein#add('Raimondi/delimitMate')
  call dein#add('Shougo/deoplete.nvim')
  call dein#add('bronson/vim-trailing-whitespace')
  call dein#add('christoomey/vim-tmux-navigator')
  call dein#add('ctrlpvim/ctrlp.vim')
  call dein#add('elzr/vim-json')
  call dein#add('fatih/vim-go')
  call dein#add('godlygeek/tabular')
  call dein#add('hashivim/vim-terraform')
  call dein#add('mtscout6/syntastic-local-eslint.vim')
  call dein#add('puppetlabs/puppet-syntax-vim')
  call dein#add('scrooloose/nerdcommenter')
  call dein#add('scrooloose/nerdtree')
  call dein#add('scrooloose/syntastic')
  call dein#add('tpope/vim-endwise')
  call dein#add('tpope/vim-fugitive')
  call dein#add('tpope/vim-sensible')
  call dein#add('tpope/vim-surround')
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  call dein#add('vim-ruby/vim-ruby')
  call dein#add('vim-scripts/CmdlineComplete')

  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  call dein#end()
  call dein#save_state()
endif

let g:deoplete#enable_at_startup = 1

filetype plugin indent on

set background=dark
colorscheme solarized

set autoindent
set tabstop=2
set shiftwidth=2
set expandtab

set number
set mouse=a

" Increase default buffer size for copy and pasting
" Less than 1000 lines, less than 1000kb
" https://stackoverflow.com/questions/17812111/default-buffer-size-to-copy-paste-in-vim
 set viminfo='20,<1000,s1000

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
  noremap <Right> <NOP>

set wildmode=longest,list,full
set wildmenu

syntax on

" highlight tabs
"":set list
":set listchars=tab:>-     " > is shown at the beginning, - throughout"

" 80 Column Limit
set colorcolumn=80
set textwidth=80

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
let g:syntastic_go_checkers = ['go', 'golint', 'govet', 'gometalinter']
let g:syntastic_go_gometalinter_args = ['--disable-all', '--enable=errcheck']
" vim-go
let g:go_list_type = "quickfix"
let g:go_fmt_command = "goimports"

" Easier Split Navigation
" We can use different key mappings for easy navigation between splits to save
" a keystroke. So instead of ctrl-w then j, it’s just ctrl-j:
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Highlight Non-ASCII spaces:
highlight nonascii guibg=Red ctermbg=1 term=standout
au BufReadPost * syntax match nonascii "[^\u0000-\u007F]""

" Fixes extra characters being pasted into VIM on macOS
" https://stackoverflow.com/questions/44848979/getting-strange-characters-when-pasting-into-my-iterm2-terminal
set t_BE=

" Some vim-terraform config
let g:terraform_align=1
let g:terraform_fmt_on_save=1

" Automatic Paste Mode
" https://stackoverflow.com/a/38258720/62202
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

" Highlight tabs as errors.
" https://vi.stackexchange.com/a/9353/3168
match Error /\t/
