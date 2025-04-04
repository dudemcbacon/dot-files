" Note: Skip initialization for vim-tiny or vim-small.
if !1 | finish | endif

set nocompatible              " be iMproved, required
filetype off                  " required

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
if exists('g:vscode')
  call plug#begin('~/.vim-vscode/plugged')
else
  call plug#begin('~/.vim/plugged')
endif

"Plug 'mtscout6/syntastic-local-eslint.vim', Cond(!exists('g:vscode'))
"Plug 'scrooloose/syntastic'

if exists('g:vscode')
  " VSCode extension
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'godlygeek/tabular'
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-surround'
  Plug 'flazz/vim-colorschemes'
else
  " ordinary Neovim
  Plug 'tjdevries/colorbuddy.nvim'
  Plug 'svrana/neosolarized.nvim'
  Plug 'Raimondi/delimitMate'
  Plug 'airblade/vim-gitgutter'
  Plug 'bronson/vim-trailing-whitespace'
  Plug 'christoomey/vim-tmux-navigator'
  Plug 'ctrlpvim/ctrlp.vim'
  Plug 'dense-analysis/ale'
  Plug 'dstein64/vim-startuptime'
  Plug 'elzr/vim-json'
  Plug 'fatih/vim-go'
  Plug 'flazz/vim-colorschemes'
  Plug 'ggandor/leap.nvim'
  Plug 'github/copilot.vim'
  Plug 'godlygeek/tabular'
  Plug 'hashivim/vim-terraform'
  Plug 'ludovicchabant/vim-gutentags'
  Plug 'preservim/tagbar'
  Plug 'puppetlabs/puppet-syntax-vim'
  Plug 'rhysd/vim-grammarous'
  Plug 'scrooloose/nerdcommenter'
  Plug 'tpope/vim-bundler'
  Plug 'tpope/vim-endwise'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rails'
  Plug 'tpope/vim-sensible'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-vinegar'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'vim-ruby/vim-ruby'
  "Plug 'vim-scripts/CmdlineComplete'

  if has('nvim')
    "Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-vsnip'
    Plug 'hrsh7th/vim-vsnip'
  else
    "Plug 'Shougo/deoplete.nvim'
    Plug 'roxma/nvim-yarp'
    Plug 'roxma/vim-hug-neovim-rpc'
  endif
endif

let g:grammarous#jar_url = 'https://www.languagetool.org/download/LanguageTool-5.9.zip'

let g:deoplete#enable_at_startup = 1

" Initialize plugin system
call plug#end()

" :w!! to write as root
cmap w!! w !sudo tee > /dev/null %

" ale
let b:ale_fixers = ['prettier', 'eslint']
let g:ale_open_list=1
" close loclist when buffer is closed
" https://github.com/dense-analysis/ale/blob/483d056528543df3349299db1ecf4aecfd0d7f44/doc/ale.txt#L1873
augroup CloseLoclistWindowGroup
  autocmd!
  autocmd QuitPre * if empty(&buftype) | lclose | endif
augroup END

" Set TagBar to toggle with F8
nmap <F8> :TagbarToggle<CR>

" Set them
syntax enable
set termguicolors
set background=dark

" Default indentation
set autoindent
set tabstop=2
set shiftwidth=2
set expandtab

" Indentation for java
autocmd FileType java setlocal shiftwidth=4 softtabstop=4 expandtab

set number
set mouse=a

" Increase default buffer size for copy and pasting
" Less than 1000 lines, less than 1000kb
" https://stackoverflow.com/questions/17812111/default-buffer-size-to-copy-paste-in-vim
 set viminfo='20,<1000,s1000

" Disable arrow keys
if !exists('g:vscode')
  noremap <Up> <NOP>
  noremap <Down> <NOP>
  noremap <Left> <NOP>
  noremap <Right> <NOP>
endif

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
if !exists('g:vscode')
  inoremap jk <esc>
  inoremap <esc> <nop>
endif

" vim-airline options
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_solarized_bg='dark'

" gutentags
let g:gutentags_cache_dir='~/.gutentags'
set statusline+=%{gutentags#statusline()}
let g:gutentags_ctags_exclude = [
\ '.git/*',
\ '.husky/*',
\ '.vscode/*',
\ 'node_modules',
\ 'spec/*',
\ 'temp/*',
\ 'test/*',
\]

" Recommended Syntastic Settings
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
" Check debug messages with :mes
"let g:syntastic_debug = 33
"let g:syntastic_go_checkers = ['go', 'gofmt', 'govet']
"let g:syntastic_always_populate_loc_list = 1
"let g:syntastic_auto_loc_list = 1
"let g:syntastic_check_on_open = 1
"let g:syntastic_check_on_wq = 0
"let g:syntastic_eruby_ruby_quiet_messages =
""    \ {'regex': 'possibly useless use of a variable in void context'}
"let g:syntastic_javascript_checkers = ['eslint']

"let g:syntastic_go_checkers = ['go', 'golint', 'govet', 'gometalinter']
"let g:syntastic_go_gometalinter_args = ['--disable-all', '--enable=errcheck']
"let g:syntastic_java_checkers=['javac']
"let g:syntastic_java_javac_config_file_enabled = 1
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

" deoplete
let g:loaded_perl_provider = 0
if has("unix")
  let s:uname = system("uname")
  if s:uname == "Darwin\n"
    " Do Mac stuff here
    " deoplete python
    "let g:python2_host_prog = '/Users/bburnett/development/py2nvim/bin/python'
    "let g:python3_host_prog = '/Users/bburnett/development/py3nvim/bin/python'
  endif
endif

lua << EOF
  require('neosolarized').setup({
    comment_italics = true,
    background_set = false,
  })
EOF

colorscheme neosolarized

lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'vsnip' }, -- For vsnip users.
      -- { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
  -- Set configuration for specific filetype.
  --[[ cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'git' },
    }, {
      { name = 'buffer' },
    })
 })
 require("cmp_git").setup() ]]-- 

  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
  })

  -- Set up lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
EOF
