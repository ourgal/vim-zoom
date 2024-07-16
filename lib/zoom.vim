vim9script

export class Zoom
  var enable: bool = false
  var session_file: string = ''
  var qflist: list<dict<any>> = [{}]

  def IsOnlyWindow(): bool
    return tabpagebuflist()->len() == 1
  enddef

  def CleanSessionFile()
    if !empty(this.session_file)
      delete(this.session_file)
    endif
  enddef

  def SetSessionFile(): string
    if empty(this.session_file) || !filereadable(this.session_file)
      this.session_file = tempname() .. '_' .. tabpagenr()
      if exists('##TabClosed')
        autocmd TabClosed * this.CleanSessionFile()
      elseif exists('##TabLeave')
        autocmd TabLeave * this.CleanSessionFile()
      endif
    endif
    return this.session_file
  enddef

  def Toggle()
    if this.enable
      if exists('#User#ZoomPre')
        doautocmd User ZoomPre
      endif

      const cursor_pos = getpos('.')
      const current_buffer = bufnr('')
      exec 'silent! source' this.SetSessionFile()
      setqflist(this.qflist)
      silent! exe 'b' .. current_buffer
      this.enable = false
      cursor_pos->setpos('.')

      if exists('#User#ZoomPost')
        doautocmd User ZoomPost
      endif
    else
      # skip if only window
      if this.IsOnlyWindow() | return | endif

      const oldsessionoptions = &sessionoptions
      set sessionoptions-=tabpages
      if matchstr(&sessionoptions, 'sesdir') == ''
        set sessionoptions+=blank,buffers,curdir,terminal,help
      else
        set sessionoptions+=blank,buffers,terminal,help
      endif
      this.qflist = getqflist()
      exec 'mksession!' this.SetSessionFile()
      wincmd o
      this.enable = true
      &sessionoptions = oldsessionoptions
    endif
  enddef

  def Statusline(): string
    if this.enable
      return get(g:, 'zoom#statustext', 'zoomed')
    endif
    return ''
  enddef

endclass
