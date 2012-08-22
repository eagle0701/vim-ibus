" ibus.vim	   remember ibus's input state for each buffer
" Original Script: https://github.com/bouzuya/vim-ibus.git
" Modified By:     eagle
" Version:	   1.0
" ---------------------------------------------------------------------

scriptencoding utf-8
" Exit when this plugin has been loaded, vi compatible mode set, or vim
" don't support python
if exists("g:loaded_ibus") || &cp || !has('python')
  finish
endif

let g:loaded_ibus = 1.0

let s:keepcpo           = &cpo
set cpo&vim

" ------------------------------------------------------------
" Define functions to Call when enter or leave Insert Mode
" ------------------------------------------------------------
function! s:leaveInsertMode()
  " Store last IBus state when in Insert Mode
  if s:is_enabled()
      let b:laststat = 1
  endif
  call s:disable()
endfunction

function! s:enterInsertMode()
  if exists("b:laststat") && b:laststat == 1
    call s:enable()
  else
    let b:laststat=0
  endif
endfunction

autocmd InsertLeave * call s:leaveInsertMode()
autocmd InsertEnter * call s:enterInsertMode()

" ------------------------------------------------------------
" Define functions to communicate with IBus
" ------------------------------------------------------------
function! s:is_enabled()
  python << EOT
import vim
import ibus
bus = ibus.Bus()
ic = ibus.InputContext(bus, bus.current_input_contxt())
vim.command('let ibus_is_enabled = ' + str(ic.is_enabled()))
EOT
  return ibus_is_enabled
endfunction

function! s:enable()
  python << EOT
import ibus
bus = ibus.Bus()
ic = ibus.InputContext(bus, bus.current_input_contxt())
if not ic.is_enabled():
    ic.enable()
EOT
endfunction

function! s:disable()
  python << EOT
import ibus
bus = ibus.Bus()
ic = ibus.InputContext(bus, bus.current_input_contxt())
if ic.is_enabled():
    ic.disable()
EOT
endfunction

"  ---------------------------------------------------------
let &cpo= s:keepcpo
unlet s:keepcpo
