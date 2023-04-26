"source $VIMRUNTIME/defaults.vim
set mouse=
set ttymouse=xterm

set t_Co=256
color xoria256
set background=dark

set termguicolors

"add cursorline
set cursorline

"leave background alone if running in terminal
if !has("gui_running")
  "no background?
  autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE
  "do not change colors of fg on cursorline
  autocmd ColorScheme * highlight CursorLine ctermfg=NONE
  autocmd ColorScheme * highlight EndOfBuffer ctermfg=NONE
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

"key mappings
""tabs
:map <C-j> :tabp <CR>
:map <C-k> :tabn <CR>
:map <C-n> :tabe <CR>:E <CR>
"remap autocomplete
inoremap <Nul> <C-x><C-o>


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

set statusline+=%{mode()}
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
"
set nofoldenable    " disable folding

set guioptions+=a

set display+=uhex

"""ss format
set expandtab
set tabstop=2
set shiftwidth=2

autocmd FileType php set makeprg=php\ -l\ %
autocmd FileType c,cpp set makeprg=gcc\ -Wall\ -Wstrict-prototypes\ -Wmissing-prototypes\ -Wshadow\ -Wconversion\ %
autocmd FileType c,cpp,sh,gitconfig setlocal noexpandtab softtabstop=0 shiftwidth=2

packadd! vim-javascript

"vimspector
packadd! vimspector
"let g:vimspector_enable_mappings = 'HUMAN'
let g:vimspector_ui_mode = 'horizontal'
:map <F2> <Plug>VimspectorStepOver
:map <F3> <Plug>VimspectorStepInto
:map <F4> <Plug>VimspectorStepOut
:map <F5> <Plug>VimspectorContinue
:map <F6> <Plug>VimspectorBalloonEval
:map <F8> <Plug>VimspectorAddFunctionBreakpoint
:map <F9> <Plug>VimspectorRunToCursor
:map <F10> <Plug>VimspectorToggleBreakpoint
:map <F11> <Plug>VimspectorUpFrame
:map <F12> <Plug>VimspectorDownFrame
:map <Leader>b <Plug>VimspectorBreakpoints



"""unused below



"simple resize
"set winwidth=100
"autocmd VimEnter * :call SetWins()
"function SetWins()
"  let min=(&columns / 2) - 1
"  if min < &columns
"    let &winwidth=min
"  else
"    let min=(&min / 2) - 1
"    let &winwidth=min
"  end
"endfunction

""autoresize windows
"augroup ReduceNoise
"    autocmd!
"    " Automatically resize active split to 85 width
"    autocmd WinEnter * :call ResizeSplits()
"augroup END
"
"function! ResizeSplits()
"    if &ft == 'nerdtree'
"        return
"    elseif &ft == 'qf'
"        " Always set quickfix list to a height of 10
"        resize 10
"        return
"    else
"        set winwidth=50%
"        wincmd =
"    endif
"endfunction


"""vdebug
""toggle bp window
":map <Leader>b :BreakpointWindow <CR>
"let g:vdebug_options = {}
"let g:vdebug_options.port = 9000
"let g:vdebug_options.watch_window_style = 'compact'
"let g:vdebug_options.simplified_status = 1
"let g:vdebug_options.continuous_mode = 1
"let g:vdebug_options.break_on_open = 0
"let g:vdebug_options.debug_window_level = 0
"let g:vdebug_options.layout = 'vertical'
""let g:vdebug_options.debug_file_level = 2
""let g:vdebug_options.debug_file = '/tmp/vdebug.log'
"
""get the proper source directory on this machine
"if (isdirectory('/home/git/dev_lamp/sitscape/apache2.2/htdocs/ss'))
"  let ss_source='/home/git/dev_lamp/sitscape/apache2.2/htdocs/ss'
"elseif (isdirectory('/var/tmp/git/sitscape/apache2.2/htdocs/ss'))
"  let ss_source='/var/tmp/git/sitscape/apache2.2/htdocs/ss'
"elseif (isdirectory('/SitscapeData/SOURCE/ss'))
"  let ss_source='/SitscapeData/SOURCE/ss'
"else
"  let ss_source='/var/www/ss'
"endif
"
""target directory
"let g:vdebug_options.path_maps = {'/var/www/ss':ss_source,}
"
""default keymap for reference (or customization)
"let g:vdebug_keymap = {
"    \    "run" : "<F5>",
"    \    "run_to_cursor" : "<F9>",
"    \    "step_over" : "<F2>",
"    \    "step_into" : "<F3>",
"    \    "step_out" : "<F4>",
"    \    "close" : "<F6>",
"    \    "detach" : "<F7>",
"    \    "set_breakpoint" : "<F10>",
"    \    "get_context" : "<F11>",
"    \    "eval_under_cursor" : "<F12>",
"    \    "eval_visual" : "<Leader>e",
"    \}
""breakpoint colors
"hi default DbgBreakptLine term=reverse ctermfg=none ctermbg=DarkGrey guifg=#ffffff guibg=#0000ff
"hi default DbgCurrentLine term=reverse ctermfg=none ctermbg=Red guifg=#ffffff guibg=#ff0000
"hi default DbgDisabledLine term=reverse ctermbg=none ctermfg=Cyan guibg=#b4ee9a guifg=#888888
"hi default DbgBreakptSign term=reverse ctermfg=White ctermbg=DarkBlue guifg=#ffffff guibg=#0000ff

set wildmenu
set wildmode=longest:full,full
if v:version > 900
  set wildoptions=pum,fuzzy
endif

"line numbers
nmap <silent> <c-l> :exec &nu==&rnu? "se nu!" : "se rnu!"<CR>
