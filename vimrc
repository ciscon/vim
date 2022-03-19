source $VIMRUNTIME/defaults.vim
set mouse=
"set mouse-=a

"filetype off
"force 256 colors
"set t_Co=256
"" set Vim-specific sequences for RGB colors
"colorscheme bubblegum-256-dark
"color zenburn
color jellybeans
set background=dark

"add cursorline
set cursorline

"leave background alone if running in terminal
if !has("gui_running")
  autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
endif


filetype plugin indent on
syntax enable

"filetype plugin indent on    " required
"filetype off

"just disable backup/swap files
set noswapfile
set nobackup

"change cwd to that of file opened
set autochdir

"write changes to vimrc?
set modifiable

"gvim
"if has('gui_running')
"set guifont=Terminus\ 10
"colorscheme evening
"colorscheme delek
"colors evening
"endif

"key mappings


""tabs
:map <C-j> :tabp <CR>
:map <C-k> :tabn <CR>
:map <C-n> :tabe <CR>:E <CR>


" file is large from 10mb
let g:LargeFile = 1024 * 1024 * 10
augroup LargeFile
    autocmd BufReadPre * let f=getfsize(expand("<afile>")) | if f > g:LargeFile || f == -2 | call LargeFile() | endif
augroup END

function LargeFile()
    " no syntax highlighting etc
    set eventignore+=FileType
    " save memory when other file is viewed
    setlocal bufhidden=unload
    " is read-only (write with :w new_filename)
    setlocal buftype: ""
    "setlocal buftype=nowrite
    " no undo possible
    setlocal undolevels=-1
    " display message
    autocmd VimEnter *  echo "The file is larger than " . (g:LargeFile / 1024 / 1024) . " MB, so some options are changed (see .vimrc for details)."
endfunction

"don't wrap git commit messages
autocmd Syntax gitcommit setlocal textwidth=0
autocmd BufNewFile,BufRead *.html set syntax=php

"set paste

"let php_folding = 1        "Set PHP folding of classes and functions.
"let php_htmlInStrings = 1  "Syntax highlight HTML code inside PHP strings.
"let php_sql_query = 1      "Syntax highlight SQL code inside PHP strings.
"let php_noShortTags = 1    "Disable PHP short tags.
"set nocompatible          " Because filetype detection doesn't work well in compatible mode
"filetype plugin indent on " Turns on filetype detection, filetype plugins, and filetype indenting all of which add nice extra features to whatever language you're using
"syntax enable             " Turns on filetype detection if not already on, and then applies filetype-specific highlighting.

"set foldmethod=indent
set ruler



"set shiftwidth=4
"set softtabstop=4
"highlight! link DiffText MatchParen

"highlight DiffAdd cterm=none ctermfg=bg ctermbg=Green gui=none guifg=bg guibg=Green
"highlight DiffDelete cterm=none ctermfg=bg ctermbg=Red gui=none guifg=bg guibg=Red
"highlight DiffChange cterm=none ctermfg=bg ctermbg=Yellow gui=none guifg=bg guibg=Yellow
"highlight DiffText cterm=none ctermfg=bg ctermbg=Magenta gui=none guifg=bg guibg=Magenta



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=500

"Always show current position
set ruler

" Highlight search results
set hlsearch

" For regular expressions turn magic on
set magic

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Return to last edit position when opening files (You want this!)
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" vim -b : edit binary using xxd-format!
augroup Binary
  au!
  au BufReadPre  *.bin let &bin=1
  au BufReadPost *.bin if &bin | %!xxd
  au BufReadPost *.bin set ft=xxd | endif
  au BufWritePre *.bin if &bin | %!xxd -r
  au BufWritePre *.bin endif
  au BufWritePost *.bin if &bin | %!xxd
  au BufWritePost *.bin set nomod | endif
augroup END


"remove trailing whitespace and reformat without losing postition
"function! Preserve(command)
"    " Preparation: save window state
"    let l:saved_winview = winsaveview()
"    " Run the command:
"    execute a:command
"    " Clean up: restore previous window position
"    call winrestview(l:saved_winview)
"endfunction
"nnoremap <F5> :call Preserve("normal gg=G") <BAR>:call Preserve("%s/\\s\\+$//e")<CR>

set noshowmode

"statusline
"
let g:airline_disabled = 1

set statusline+=%#PmenuSel#
set statusline+=%#LineNr#
set statusline+=\ %F
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c

set laststatus=2
"set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c



"slow inserts
"set foldmethod=syntax
"set foldlevel=999

set guioptions+=a

set display+=uhex

"""ss format
set expandtab
set tabstop=2
set shiftwidth=2

autocmd FileType php set makeprg=php\ -l\ %
autocmd FileType c,cpp set makeprg=gcc\ -Wall\ -Wstrict-prototypes\ -Wmissing-prototypes\ -Wshadow\ -Wconversion\ %
autocmd FileType c,sh setlocal noexpandtab softtabstop=0 shiftwidth=4
set tabstop=4


"autoresize windows
augroup ReduceNoise
    autocmd!
    " Automatically resize active split to 85 width
    autocmd WinEnter * :call ResizeSplits()
augroup END

function! ResizeSplits()
    set winwidth=85
    wincmd =
endfunction


""vdebug
"toggle bp window
:map <Leader>b :BreakpointWindow <CR>
let g:vdebug_options = {}
let g:vdebug_options.port = 9000
let g:vdebug_options.watch_window_style = 'compact'
"get the proper source directory on this machine
if (isdirectory('/home/git/dev_lamp/sitscape/apache2.2/htdocs/ss'))
  let ss_source='/home/git/dev_lamp/sitscape/apache2.2/htdocs/ss'
elseif (isdirectory('/var/tmp/git/sitscape/apache2.2/htdocs/ss'))
  let ss_source='/var/tmp/git/sitscape/apache2.2/htdocs/ss'
elseif (isdirectory('/SitscapeData/SOURCE/ss'))
  let ss_source='/SitscapeData/SOURCE/ss'
else
  let ss_source='/var/www/ss'
endif

"target directory
let g:vdebug_options.path_maps = {'/var/www/ss':ss_source,}

"default keymap for reference (or customization)
let g:vdebug_keymap = {
    \    "run" : "<F5>",
    \    "run_to_cursor" : "<F9>",
    \    "step_over" : "<F2>",
    \    "step_into" : "<F3>",
    \    "step_out" : "<F4>",
    \    "close" : "<F6>",
    \    "detach" : "<F7>",
    \    "set_breakpoint" : "<F10>",
    \    "get_context" : "<F11>",
    \    "eval_under_cursor" : "<F12>",
    \    "eval_visual" : "<Leader>e",
    \}
"breakpoint colors
hi default DbgBreakptLine term=reverse ctermfg=White ctermbg=DarkGrey guifg=#ffffff guibg=#0000ff
hi default DbgBreakptSign term=reverse ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#0000ff
