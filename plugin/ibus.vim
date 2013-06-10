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

let s:keepcpo           = &cpo
set cpo&vim

" ------------------------------------------------------------
" Define functions to Call when enter or leave Insert Mode
" ------------------------------------------------------------
function! s:leaveInsertMode()
  " Store last IBus state when in Insert Mode
  if s:is_enabled()
      let b:laststat = 1
      call s:disable()
  else
    let b:laststat=0
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
" Define functions to communicate with IBus
" ------------------------------------------------------------
function! s:is_enabled()
  python3 << EOT
import vim
from gi.repository import IBus
IBus.init()
bus = IBus.Bus()
ic=IBus.InputContext.get_input_context(bus.current_input_context(),bus.get_connection())
#vim.command('let ibus_is_enabled = ' + str(ic.is_enabled()))
if ic.is_enabled():
  vim.command('let ibus_is_enabled = 1')
else:
  vim.command('let ibus_is_enabled = 0')
EOT
  return ibus_is_enabled
endfunction

function! s:enable()
  python3 << EOT
from gi.repository import IBus
IBus.init()
bus = IBus.Bus()
ic=IBus.InputContext.get_input_context(bus.current_input_context(),bus.get_connection())
if not ic.is_enabled():
    ic.enable()
EOT
endfunction

function! s:disable()
  python3 << EOT
from gi.repository import IBus
IBus.init()
bus = IBus.Bus()
ic=IBus.InputContext.get_input_context(bus.current_input_context(),bus.get_connection())
if ic.is_enabled():
    ic.disable()
EOT
endfunction

"  ---------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo
