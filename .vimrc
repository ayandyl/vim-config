set nocompatible " must be first line
scriptencoding utf-8

" ====================
" editing
" ====================

let mapleader = ',' " use ',' for <leader>

set nospell

set virtualedit=onemore                        " cursor one beyond last character
set backspace=indent,eol,start
set showmatch                                  " show matching brackets/parens
set cursorline                                 " highlight current line
set colorcolumn=80                             " show 80-char indicator
set incsearch                                  " find as you type search
set hlsearch                                   " highlight serach terms
set ignorecase                                 " case insensitive search
set smartcase                                  " case sensitive when uppercase present
set magic                                      " magic on for regex
set wildmenu                                   " show list instead of just completing
set wildmode=list:longest,full                 " <Tab> completion
set whichwrap=b,s,h,l,<,>,[,]                  " backspace and cursor keys wrap too
set scrolljump=5                               " lines to scroll when cursor leaves screen
set scrolloff=3                                " minimum lines to keep above and below cursor
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " highlight problematic whitespace
set wrap linebreak

set smartindent
set expandtab smarttab
set shiftwidth=2 tabstop=2 softtabstop=2
set nojoinspaces " do not insert two spaces after punctuation on a join (J)
set splitbelow   " new split windows to the below of current
set nosplitright " new vsplit windows to the left of current

" remove trailing whitespaces and ^M chars for all files
augroup remove_whitespace
  autocmd!
  autocmd BufWritePre * :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
augroup END

" map 'jk' to Esc
inoremap jk <Esc>
inoremap Jk <Esc>
inoremap jK <Esc>
inoremap JK <Esc>

" jump between windows
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-h> <C-W>h
noremap <C-l> <C-W>l

" wrapped lines
noremap j gj
noremap k gk

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>

" Adjust viewports to the same size
map <Leader>= <C-w>=

" fast save all buffers
noremap <leader>w :wa!<cr>
" update file when changed on disk
noremap <leader>ct :checktime<cr>
" print full file path
noremap <leader>pf :put =expand('%:p')<cr>

" close current buffer
noremap <leader>bd :Bclose<cr>
  " don't close window when deleting a buffer
  command! Bclose call <SID>BufcloseCloseIt()
  function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = bufnr("#")

    if buflisted(l:alternateBufNum)
      buffer #
    else
      bnext
    endif

    if bnfnr("%") == l:currentBufNum
      new
    endif

    if buflisted(l:currentBufNum)
      execute("bdelete! ".l:currentBufNum)
    endif
  endfunction
" close all buffers
noremap <leader>ba :%bd!<cr>

" switch buffer behavior
try
  set switchbuf=USEOPENsetab,newtab
catch
endtry

" open and close quickfix window
noremap <leader>qo :copen<cr>
noremap <leader>qc :cclose<cr>

" grep with ag, put results in "quickfix" window
if executable('ag')
  set grepprg=ag\ --nogroup\ --nocolor\ --hidden\ --ignore\ /.git/
  command -nargs=+ -complete=file -bar Ag silent! grep! <args> %:p:h|cwindow|redraw!
  nnoremap <leader>gg :Ag<space>
endif

" open all folds
nnoremap <leader>fo :set foldlevel=99<cr>

if has('clipboard') " use + for copy-paste
  set clipboard=unnamed,unnamedplus
endif

set hidden " allow buffer switching without saving

" turn off backups, we have source control
set nobackup nowb noswapfile

" from spf13
" End/Start of line motion keys act relative to row/wrap width in the
" presence of `:set wrap`, and relative to line for `:set nowrap`.
" Default vim behaviour is to act relative to text line in both cases
function! WrapRelativeMotion(key, ...)
  let vis_sel=""
  if a:0
    let vis_sel="gv"
  endif
  if &wrap
    execute "normal!" vis_sel . "g" . a:key
  else
    execute "normal!" vis_sel . a:key
  endif
endfunction
" Map g* keys in Normal, Operator-pending, and Visual+select
noremap $ :call WrapRelativeMotion("$")<CR>
noremap <End> :call WrapRelativeMotion("$")<CR>
noremap 0 :call WrapRelativeMotion("0")<CR>
noremap <Home> :call WrapRelativeMotion("0")<CR>
noremap ^ :call WrapRelativeMotion("^")<CR>
" Overwrite the operator pending $/<End> mappings from above
" to force inclusive motion with :execute normal!
onoremap $ v:call WrapRelativeMotion("$")<CR>
onoremap <End> v:call WrapRelativeMotion("$")<CR>
" Overwrite the Visual+select mode mappings from above
" to ensure the correct vis_sel flag is passed to function
vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>

" from spf13
" accidental shift key fixes
if has("user_commands")
    command! -bang -nargs=* -complete=file E e<bang> <args>
    command! -bang -nargs=* -complete=file W w<bang> <args>
    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
    command! -bang Wa wa<bang>
    command! -bang WA wa<bang>
    command! -bang Q q<bang>
    command! -bang QA qa<bang>
    command! -bang Qa qa<bang>
endif
cmap Tabe tabe

" yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

set history=1000 " store lots of history (default 50!)
if has('persistent_undo')
  set undofile
  set undolevels=1000
  set undoreload=10000
endif

" '.', '#', '-' are end of word designators
set iskeyword-=.
set iskeyword-=#
set iskeyword-=-

" return to last edit position when opening files
augroup restore_cursor
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \ exe "normal! g`\"" |
    \ endif
augroup END
" remember info about open buffers on close
set viminfo^=%

set autoread " auto read a file if changed externally

" ====================
" UI
" ====================

" no mouse! prevent accidental clicks on touchpad
set mouse-=a
set mousehide

set background=dark

try
  let g:solarized_termcolors = 256
  let g:solarized_termtrans = 1
  let g:solarized_contrast = "normal"
  let g:solarized_visibility = "normal"
  colorscheme solarized
  "colorscheme southernlights
catch /^Vim\%((\a\+)\)\=:E185/
endtry

set shortmess=aoOstTS " shorter messages, avoids 'hit enter'
set viewoptions=cursor,folds,options,slash,unix

set tabpagemax=15
set showmode       " display the current mode

set linespace=0    " no extra space between rows
set winminheight=0 " windows can be 0 line high
set number         " line numbers on

" from spf13
if has('cmdline_info')
  set ruler
  set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
  set showcmd
endif

" from spf13
if has('statusline')
  set laststatus=2
  set statusline=%<%f\                     " Filename
  set statusline+=%w%h%m%r                 " Options
  set statusline+=%{fugitive#statusline()} " Git Hotness
  set statusline+=\ [%{&ff}/%Y]            " Filetype
  set statusline+=\ [%{getcwd()}]          " Current dir
  set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
endif

" ====================
" plugins
" ====================

" NERDTree

let NERDTreeIgnore = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
let NERDTreeChDirMode = 0
let NERDTreeQuitOnOpen = 1
let NERDTreeShowHidden = 1

" toggle NERDTree
noremap <leader>nn :NERDTreeToggle<cr>:silent NERDTreeMirror<cr>
" locate current file in NERDTree
noremap <leader>nf :NERDTreeFind<cr>

augroup nerdtree
  autocmd!
  " open NERDTree on start, if no file specified
  autocmd StdinReadPre * let s:std_in=1
  autocmd vimenter * if !argc() | NERDTree | endif
  " close vim if only NERDTree left
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
augroup END

" CtrlP
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ }
let g:ctrlp_prompt_mappings = {
  \ 'PrtClearCache()': ['<c-h>'],
  \ 'PrtCurLeft()': ['<left>', '<c-^>'],
  \ }

if executable('ag') " use ag in CtrlP, fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor --hidden -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" airline
let g:airline_theme = 'solarized'
" wordcount is bugged, throws undefined variables; plus not needed anyway
let g:airline#extensions#wordcount#enabled=0
" no need to remind me about all the unix utf8 files
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'

" deoplete.nvim
let g:deoplete#enable_at_startup = 1

" markdown
let g:markdown_enable_spell_checking = 0      " remove spell check
let g:markdown_enable_input_abbreviations = 0 " remove ":-)" -> ":smile:"

" vim-json
let g:vim_json_syntax_conceal = 0 " do not conceal ""'s

" rainbow (html tag etc rainbow highlighting)
let g:rainbow_active = 1

" vim-indent-guides
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1

" ====================
" languages
" ====================

" filetype should default to unix, but dos more practical than mac
set ffs=unix,dos,mac

filetype plugin indent on " automatically detect file types
syntax on

" Find merge conflict markers
" DEPRECATED conflict-marker.vim has [x and ]x
" also available: co (ours) ct (theirs) cb (both) cn (none)
"map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

" instead of reverting the cursor to the last position in the buffer,
" set it to the first line when editing a git commit message
au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

augroup r
  autocmd!
  " we don't use lisp-style
  autocmd BufRead,BufNewFile *.r set indentexpr=""
augroup END

" =============================
" local-specific
" =============================

" my usual dir for dev work
cd /code
