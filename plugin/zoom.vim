if !has('vim9script') ||  v:version < 900
    finish
endif
vim9script

if !exists('g:zoom_tmux_z')
  g:zoom_tmux_z = false
endif

import autoload '../lib/zoom.vim' as lib

const zoom = lib.Zoom.new()

nnoremap <silent> <Plug>(zoom-toggle) <scriptcmd>zoom.Toggle()<CR>

if !hasmapto('<Plug>(zoom-toggle)')
  nmap <C-W>m <Plug>(zoom-toggle)
endif
if empty($TMUX) == 1 && g:zoom_tmux_z == true
  nmap <C-W>z <Plug>(zoom-toggle)
endif
