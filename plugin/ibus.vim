" ibus.vim	   remember ibus's input state for each buffer
" Original Script: https://github.com/bouzuya/vim-ibus.git
" Modified By:     eagle
" Version:	   1.1
" ---------------------------------------------------------------------

scriptencoding utf-8
" Exit when this plugin has been loaded, vi compatible mode set, or vim
" don't support python3
if exists("g:loaded_ibus") || &cp
  finish
endif

function! s:CriticalError(message)
	echohl ErrorMsg
	echomsg a:message
	echohl None
endfunction

if ! has('python3') && ! has('python')
	call s:CriticalError('You need vim compiled with Python 2.6+ or 3.2+ support
		\ for Powerline to work. Please consult the documentation for more details.')
	finish
endif

let g:loaded_ibus = 1.1

let s:keepcpo           = &cpo
set cpo&vim

let s:vim_ibus_init = 0

let s:pycmd = has('python3') ? 'py3' : 'py'

" ------------------------------------------------------------
" Define functions to Call when enter or leave Insert Mode
" ------------------------------------------------------------
function! s:leaveInsertMode()
  " Store last IBus state when in Insert Mode
  if s:ibus_init()
    if s:is_enabled()
      let b:laststat = 1
      call s:disable()
    else
      let b:laststat=0
    endif
  endif
endfunction

function! s:enterInsertMode()
  if exists("b:laststat") && b:laststat == 1
    call s:enable()
  endif
endfunction

autocmd InsertLeave * call s:leaveInsertMode()
autocmd InsertEnter * call s:enterInsertMode()



" ------------------------------------------------------------
" GVim
" ------------------------------------------------------------
" IBus.current_input_context will change when we create a new buffer in GVim
if has('gui_running')
  autocmd BufCreate * let s:vim_ibus_init = 0
endif

" ------------------------------------------------------------
" Init vim-ibus
" ------------------------------------------------------------
function! s:ibus_init()
if s:vim_ibus_init == 0
  exec s:pycmd "import vim"
  exec s:pycmd "from gi.repository import IBus"
  exec s:pycmd "IBus.init()"
  exec s:pycmd "bus = IBus.Bus()"
  exec s:pycmd "if bus.current_input_context() is not None:\n"
                   \ . "   vim_ibus_ic=IBus.InputContext.get_input_context(bus.current_input_context(),bus.get_connection())\n"
                   \ . "   vim.command('let s:vim_ibus_init = 1')\n"
                   \ . "else:\n"
                   \ . "   vim.command('let s:vim_ibus_init = 0')"
endif
return s:vim_ibus_init
endfunction

" ------------------------------------------------------------
" Define functions to communicate with IBus
" ------------------------------------------------------------
function! s:is_enabled()
exec s:pycmd "import vim"
exec s:pycmd "if vim_ibus_ic.is_enabled():\n"
                 \ . "  vim.command('let ibus_is_enabled = 1')\n"
                 \ . "else:\n"
                 \ . "  vim.command('let ibus_is_enabled = 0')"
  return ibus_is_enabled
endfunction

function! s:enable()
exec s:pycmd "if not vim_ibus_ic.is_enabled():\n"
                 \ . "    vim_ibus_ic.enable()"
endfunction

function! s:disable()
exec s:pycmd "if vim_ibus_ic.is_enabled():\n"
                 \ . "    vim_ibus_ic.disable()"
endfunction

"  ---------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo
