" ibus.vim	   remember ibus's input state for each buffer
" Original Script: https://github.com/bouzuya/vim-ibus.git
" Modified By:     eagle
" Version:	   1.1
" ---------------------------------------------------------------------

scriptencoding utf-8
" Exit when this plugin has been loaded, vi compatible mode set, or vim
" don't support python3
if exists("g:loaded_ibus") || &cp || !has('python3')
  finish
endif

let g:loaded_ibus = 1.1
let s:vim_ibus_init = 0

let s:keepcpo           = &cpo
set cpo&vim

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
" FIXME:GVim need to init ibus connection every time
if s:vim_ibus_init == 0
  python3 << EOT
import vim
from gi.repository import IBus
IBus.init()
bus = IBus.Bus()
if bus.current_input_context() is not None:
    vim_ibus_ic=IBus.InputContext.get_input_context(bus.current_input_context(),bus.get_connection())
    vim.command('let s:vim_ibus_init = 1')
else:
    vim.command('let s:vim_ibus_init = 0')
EOT
endif
return s:vim_ibus_init
endfunction

" ------------------------------------------------------------
" Define functions to communicate with IBus
" ------------------------------------------------------------
function! s:is_enabled()
  python3 << EOT
import vim
#vim.command('let ibus_is_enabled = ' + str(vim_ibus_ic.is_enabled()))
if vim_ibus_ic.is_enabled():
  vim.command('let ibus_is_enabled = 1')
else:
  vim.command('let ibus_is_enabled = 0')
EOT
  return ibus_is_enabled
endfunction

function! s:enable()
  python3 << EOT
if not vim_ibus_ic.is_enabled():
    vim_ibus_ic.enable()
EOT
endfunction

function! s:disable()
  python3 << EOT
if vim_ibus_ic.is_enabled():
    vim_ibus_ic.disable()
EOT
endfunction

"  ---------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo
