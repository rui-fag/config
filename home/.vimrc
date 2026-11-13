" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" TAB size = 4
set tabstop=4

" Indent size = 4
set shiftwidth=4

" Turn syntax highlighting on.
syntax on

" Add numbers
set number

" Clipboard support
set clipboard=unnamedplus

" Colorscheme retrobox
set background=dark
colorscheme retrobox

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" toggle hybrid line numbers
:set number relativenumber
:set nu rnu

" add termdebug
packadd! termdebug
" Place GDB windows on the right side in a wide split layout
if !exists('g:termdebug_config')
  let g:termdebug_config = {}
endif
let g:termdebug_config['wide'] = 1


" Automatically open the GDB variable window on startup
let g:termdebug_config = {'variables_window': v:true}

set mouse=a

" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ y:\ %l\ x:\ %c\ %p%%
set statusline+=\ matches:\ %{searchcount().current}/%{searchcount().total}

" Show the status on the second to last line.
set laststatus=2

" }}}
"
" Vimtex
" This is necessary for VimTeX to load properly. The "indent" is optional.
" Note: Most plugin managers will do this automatically!
filetype plugin indent on

" This enables Vim's and neovim's syntax-related features. Without this, some
" VimTeX features will not work (see ":help vimtex-requirements" for more
" info).
" Note: Most plugin managers will do this automatically!
syntax enable

" Viewer options: One may configure the viewer either by specifying a built-in
" viewer method:
let g:vimtex_view_method = 'zathura'

" Or with a generic interface:
" let g:vimtex_view_general_viewer = 'mupdf'
" let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

" VimTeX uses latexmk as the default compiler backend. If you use it, which is
" strongly recommended, you probably don't need to configure anything. If you
" want another compiler backend, you can change it as follows. The list of
" supported backends and further explanation is provided in the documentation,
" see ":help vimtex-compiler".
let g:vimtex_compiler_method = 'latexmk'

let g:vimtex_compiler_latexmk = {
  \ 'build_dir' : '',
  \ 'callback' : 1,
  \ 'continuous' : 1,
  \ 'executable' : 'latexmk',
  \ 'options' : [
  \   '-lualatex',
  \   '-shell-escape',
  \   '-file-line-error',
  \   '-interaction=nonstopmode',
  \   '-synctex=1',
  \ ],
  \}

" Most VimTeX mappings rely on localleader and this can be changed with the
" following line. The default is usually fine and is the symbol "\".
let maplocalleader = ","

" Quickfix / :make colors -------------------------------------------------- {{{
" :make pipes compiler output, so either colors vanish or (with
" -fdiagnostics-color=always / cmake_echo_color) raw ^[[...m sequences end up
" in the quickfix list and break display/parsing. The old
" 'BufReadPost quickfix' autocmds below never fired: the quickfix window has
" filetype=qf, not the filename 'quickfix', and 'containedin=ALL' clobbers
" the built-in qf.vim syntax. Fix both issues here.

" Use true colors in the terminal so quickfix highlights match other windows.
if has('termguicolors') && &term =~# '256\|true\|xterm\|screen\|tmux'
  set termguicolors
endif

" Let colorized tools emit colors even when piped through :make.
if empty($GCC_COLORS)
  let $GCC_COLORS = 'error=01;31:warning=01;35:note=01;36:range1=32:range2=34:locus=01:quote=01'
endif
let $CLICOLOR_FORCE = '1'
let $FORCE_COLOR = '1'

function! s:QfStripAnsi() abort
  " Remove ANSI escape sequences from the quickfix/location lists right after
  " :make/:grep so file:line:col still parses and no ^[[ garbage is shown.
  " NOTE: with -fdiagnostics-color=always GCC wraps even the filename
  " (^[[01m^[[Ksrc/foo.cpp), so errorformat stores a polluted bufnr. Clean
  " the buffer name too or :cc/:cnext opens a garbage filename.
  for l:is_loc in [0, 1]
    let l:list = l:is_loc ? getloclist(0) : getqflist()
    if empty(l:list)
      continue
    endif
    let l:changed = 0
    for l:item in l:list
      if has_key(l:item, 'text') && l:item.text =~# '\e\['
        let l:item.text = substitute(l:item.text, '\e\[[0-9;?]*[A-Za-z]', '', 'g')
        let l:item.text = substitute(l:item.text, '\e([AB0]', '', 'g')
        let l:item.text = substitute(l:item.text, '\r', '', 'g')
        let l:changed = 1
      endif
      if has_key(l:item, 'pattern') && l:item.pattern =~# '\e\['
        let l:item.pattern = substitute(l:item.pattern, '\e\[[0-9;?]*[A-Za-z]', '', 'g')
        let l:item.pattern = substitute(l:item.pattern, '\e([AB0]', '', 'g')
        let l:changed = 1
      endif
      if get(l:item, 'bufnr', 0) > 0
        let l:name = bufname(l:item.bufnr)
        if l:name =~# '\e\['
          let l:clean = substitute(l:name, '\e\[[0-9;?]*[A-Za-z]', '', 'g')
          let l:clean = substitute(l:clean, '\e([AB0]', '', 'g')
          let l:clean = substitute(l:clean, '\r', '', 'g')
          call remove(l:item, 'bufnr')
          let l:item.filename = l:clean
          let l:changed = 1
        endif
      elseif has_key(l:item, 'filename') && l:item.filename =~# '\e\['
        let l:item.filename = substitute(l:item.filename, '\e\[[0-9;?]*[A-Za-z]', '', 'g')
        let l:item.filename = substitute(l:item.filename, '\e([AB0]', '', 'g')
        let l:item.filename = substitute(l:item.filename, '\r', '', 'g')
        let l:changed = 1
      endif
    endfor
    if l:changed
      if l:is_loc
        call setloclist(0, l:list, 'r')
      else
        call setqflist(l:list, 'r')
      endif
    endif
  endfor
endfunction

function! s:QfAnsiSetup() abort
  " In the :copen window, conceal any leftover ANSI codes and make sure
  " errors/warnings use the colorscheme. Built-in qf.vim only matches
  " error/warning inside the |lnum| column (qfLineNr) and leaves the actual
  " message body (qfText) as Normal, plus qfWarning/qfNote/qfInfo have no
  " default highlight link at all. The Qf*Text matches below fill that gap
  " so the message itself is red/yellow, not just the filename (green).
  setlocal conceallevel=2 concealcursor=nvic
  if exists('g:syntax_on')
    silent! syntax clear QfAnsiEscape
    silent! syntax clear QfErrorText
    silent! syntax clear QfWarningText
    silent! syntax clear QfNoteText
    silent! syntax clear QfInfoText
    silent! syntax match QfAnsiEscape /\e\[[0-9;?]*[A-Za-z]/ conceal containedin=ALL
    silent! syntax match QfAnsiEscape /\e([AB0]/ conceal containedin=ALL
    silent! syntax match QfErrorText /\c\<error\>\|\<failed\>\|\<undefined\>/ contained containedin=qfText
    silent! syntax match QfWarningText /\c\<warning\>/ contained containedin=qfText
    silent! syntax match QfNoteText /\c\<note\>/ contained containedin=qfText
    silent! syntax match QfInfoText /\c\<info\>/ contained containedin=qfText
  endif
  highlight default link QfAnsiEscape Ignore
  highlight default link qfWarning WarningMsg
  highlight default link qfNote MoreMsg
  highlight default link qfInfo MoreMsg
  highlight default link QfErrorText ErrorMsg
  highlight default link QfWarningText WarningMsg
  highlight default link QfNoteText MoreMsg
  highlight default link QfInfoText MoreMsg
endfunction

augroup QuickfixAnsiColors
  autocmd!
  autocmd QuickFixCmdPost * call s:QfStripAnsi()
  " FileType fires on window creation, Syntax fires after syntax/qf.vim
  " loads (so qfText exists for containedin). Setup is idempotent.
  autocmd FileType qf call s:QfAnsiSetup()
  autocmd Syntax qf call s:QfAnsiSetup()
augroup END
" }}}

