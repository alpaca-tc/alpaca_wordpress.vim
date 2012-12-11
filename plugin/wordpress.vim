" Wordpressか判定
function! s:Detect(file_path)
  if a:file_path  =~ 'wp-'
    let b:wordpress_dir = 1
    return 1
  endif

  return 0
endfunction

" 設定
function! s:SetOptDefault(opt,val)
  if !exists("g:".a:opt)
    let g:{a:opt} = a:val
  endif
endfunction
call s:SetOptDefault("alpaca_wordpress_syntax",1)

" wordpressのau Userの設定
augroup wordpressPluginDetect
  autocmd!
  autocmd BufNewFile,BufRead * call s:Detect(expand("<afile>:p"))
  autocmd VimEnter * 
        \ if expand("<amatch>") == ""
        \|  call s:Detect(getcwd()) 
        \|endif 
        \|if exists("b:wordpress_dir") 
        \|  silent doau User BufEnterWordpress
        \|endif
  autocmd BufEnter * if exists("b:wordpress_dir") | silent doau User BufEnterWordpress|endif
  autocmd BufLeave * if exists("b:wordpress_dir") | silent doau User BufLeaveWordpress|endif
augroup END

setl noexpandtab nolist syntax=wordpress
