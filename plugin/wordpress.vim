" Wordpressか判定
function! s:Detect(filename)"{{{
  if exists('b:wordpress_root')
    return 1
  endif

  let fn = substitute(fnamemodify(a:filename,":p"),'\c^file://','','')
  let sep = matchstr(fn,'^[^\\/]\{3,\}\zs[\\/]')
  if sep != ""
    let fn = getcwd().sep.fn
  endif

  if isdirectory(fn)
    let fn = fnamemodify(fn,':s?[\/]$??')
  else
    let fn = fnamemodify(fn,':s?\(.*\)[\/][^\/]*$?\1?')
  endif
  let ofn = ""
  let nfn = fn
  while nfn != ofn && nfn != ""
    let ofn = nfn
    let nfn = fnamemodify(nfn,':h')
  endwhile
  let ofn = ""

  while fn != ofn
    if filereadable(fn . "/wp-includes/functions.php")
      let b:wordpress_dir = fn
      return 1
    endif

    let ofn = fn
    let fn = fnamemodify(ofn,':s?\(.*\)[\/]\(models\|views\|wp-admin\|wp-content\|wp-includes\)\($\|[\/].*$\)?\1?')
  endwhile

  return 0
endfunction"}}}

" 設定
function! s:SetOptDefault(opt,val)"{{{
  if !exists("g:".a:opt)
    let g:{a:opt} = a:val
  endif
endfunction"}}}
call s:SetOptDefault("alpaca_wordpress_syntax", 0)
call s:SetOptDefault("alpaca_wordpress_use_default_setting", 0)

" wordpressのau Userの設定
augroup wordpressPluginDetect
  autocmd!
  autocmd BufNewFile,BufRead * call s:Detect(expand("<afile>:p"))
  autocmd VimEnter *
        \ if expand("<amatch>") == ""
        \|  call s:Detect(getcwd())
        \|endif
  autocmd BufEnter * if exists("b:wordpress_dir") | silent doau User BufEnterWordpress|endif
  autocmd BufLeave * if exists("b:wordpress_dir") | silent doau User BufLeaveWordpress|endif
augroup END

" syntaxの読み込み
if g:alpaca_wordpress_syntax == 1 || g:alpaca_wordpress_use_default_setting == 1
  au User BufEnterWordpress if expand("%:e") == 'php' |setl syntax=wordpress| endif
endif

if g:alpaca_wordpress_use_default_setting == 1
  au User BufEnterWordpress if expand("%:e") == 'php' |setl noexpandtab nolist | endif
endif
