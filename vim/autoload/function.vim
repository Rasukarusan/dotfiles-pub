" =============================================
" clog($param)とclog("param")の相互変換関数(範囲指定も可)
" =============================================
function! s:clog_convert() range
    for currentLineNo in range(a:firstline, a:lastline)
        " 指定した行を取得
        let currentLine = getline(currentLineNo)
        let isDoller = stridx(currentLine, '$')
        if isDoller != -1
            execute ':'.currentLineNo.'s/(\$/("/g | s/)/")/g'
        else
            execute ':'.currentLineNo.'s/("/($/g | s/"//g'
        endif
    endfor
endfunction
command! -range Clog <line1>,<line2> call s:clog_convert()

" =============================================
" Gtabeditを簡単に実行できるようにした関数
" :Co [branch_name] でそのブランチのソースをタブ表示
" =============================================
function! s:alias_Gtabedit(...)
    if a:0 == 0
        let branch_name = 'master'
    else
        let branch_name = a:1
    endif
    execute ':Gtabedit '.branch_name.':%'
endfunction

function! s:fzf_alias_Gtabedit()
  call fzf#run({
    \ 'source': 'git branch -a',
    \ 'sink': function('s:alias_Gtabedit'),
    \ 'down': '40%'
    \ })
endfunction
command! Co call s:fzf_alias_Gtabedit()

" =============================================
" カーソル下の単語をPHPManualで開く
" =============================================
function! s:open_php_manual(cursor_word)
  echo a:cursor_word
  let search_word = substitute(a:cursor_word,'_','-','g')
  let url = 'http://php.net/manual/ja/function.' . search_word  . '.php'
  execute 'r! open ' . url
endfunction
command! PhpManual call s:open_php_manual(expand('<cword>'))
nmap <Space>k :PhpManual<CR>


" =============================================
" ファイル内検索
" fzfの標準関数BLinesでエラーが出るので自作
" =============================================
function! s:fzf_BLines(file_path)
  call fzf#run({
    \ 'source': 'cat -n '.a:file_path,
    \ 'sink': function('s:jump_to_line'),
    \ 'down': '40%'
    \ })
endfunction
function! s:jump_to_line(value)
    let lines = split(a:value, '\t')
    let line  = substitute(lines[0], ' ','','g')
    execute ':' . line
endfunction
nmap <C-f> :call <SID>fzf_BLines(expand('%:p'))<CR>

" =============================================
" ファイル内関数検索
" gtags_filesでエラーが出るので自作
" =============================================
function! s:fzf_ShowFunction(file_path)
  call fzf#run({
    \ 'source': 'global -f '.a:file_path. ' | awk '. "'{print $1." . '"\t"$2}' . "'",
    \ 'sink': function('s:jump_to_function'),
    \ 'down': '40%'
    \ })
endfunction
function! s:jump_to_function(value)
    let lines = split(a:value, '\t')
    execute ':' . lines[1]
endfunction
command! ShowFunction call s:fzf_ShowFunction(expand('%:p'))
nmap <Space>F :ShowFunction<CR>

" =============================================
" grepの結果からvimで開く
" スプレッドシートからコピーした場合を想定
" =============================================
function! s:jump_by_grep(...)
    let args = split(@*, ':')
    let filePath = args[0]
    let extension = fnamemodify(filePath, ":e")
    if len(args) == 1 && extension == "php"
        execute ':e ' . filePath
        return
    endif
    let line = args[1]
    execute ':e ' . filePath
    execute ':' . line
endfunction
command! -nargs=? OpenByGrep call s:jump_by_grep(<f-args>)
nmap <S-r> :OpenByGrep<CR>

" =============================================
" 選択領域をHTML化→rtf(リッチテキスト)化してクリップボードにコピーする
" Keynoteなどに貼りたい場合に便利
" =============================================
command! -nargs=0 -range=% CopyHtml call s:copy_html()
function! s:copy_html() abort
    '<,'>TOhtml
    w !textutil -format html -convert rtf -stdin -stdout | pbcopy
    bdelete!
endfunction

" =============================================
" 行頭と行末に文字列を挿入
" ex.) InTH <div> <\/div>
" =============================================
function! s:insert_head_and_tail(...) range
    let head = a:1 " 行頭に入れたい文字列
    let tail = a:2 " 行末に入れたい文字列
    " 範囲選択中かで実行するコマンドが違うので分岐
    if a:firstline == a:lastline
        execute ':%s/^/'.head.'/g | %s/$/'.tail.'/g'
    else
        execute ':'.a:firstline.','.a:lastline.'s/^/'.head.'/g | '.a:firstline.','.a:lastline."s/$/".tail.'/g'
    endif
endfunction
command! -nargs=+ -range InTH <line1>,<line2> call s:insert_head_and_tail(<f-args>)


" =============================================
" カーソル下の単語をGoogleで検索する
" =============================================
function! s:search_by_google(...)
    let line = line(".")
    let col  = col(".")
    let searchWord = expand("<cword>")
    if a:0 >= 1
        let searchWord = join(split(a:1))
        " let searchWord = printf('%s',a:1)
    end
    if searchWord  != ''
        execute 'read !open https://www.google.co.jp/search\?q\=' . searchWord
        execute 'call cursor(' . line . ',' . col . ')'
    endif
endfunction
command! -nargs=? SearchByGoogle call s:search_by_google(<f-args>)
nnoremap <silent> <Space>g :SearchByGoogle<CR>

" =============================================
" カーソル下コードのカラー名を出力
" vimでテーマを作る際に便利
" =============================================
function! s:get_syn_id(transparent)
  let synid = synID(line("."), col("."), 1)
  if a:transparent
    return synIDtrans(synid)
  else
    return synid
  endif
endfunction
function! s:get_syn_attr(synid)
  let name = synIDattr(a:synid, "name")
  let ctermfg = synIDattr(a:synid, "fg", "cterm")
  let ctermbg = synIDattr(a:synid, "bg", "cterm")
  let guifg = synIDattr(a:synid, "fg", "gui")
  let guibg = synIDattr(a:synid, "bg", "gui")
  return {
        \ "name": name,
        \ "ctermfg": ctermfg,
        \ "ctermbg": ctermbg,
        \ "guifg": guifg,
        \ "guibg": guibg}
endfunction
function! s:get_syn_info()
  let baseSyn = s:get_syn_attr(s:get_syn_id(0))
  echo "name: " . baseSyn.name .
        \ " ctermfg: " . baseSyn.ctermfg .
        \ " ctermbg: " . baseSyn.ctermbg .
        \ " guifg: " . baseSyn.guifg .
        \ " guibg: " . baseSyn.guibg
  let linkedSyn = s:get_syn_attr(s:get_syn_id(1))
  echo "link to"
  echo "name: " . linkedSyn.name .
        \ " ctermfg: " . linkedSyn.ctermfg .
        \ " ctermbg: " . linkedSyn.ctermbg .
        \ " guifg: " . linkedSyn.guifg .
        \ " guibg: " . linkedSyn.guibg
endfunction
command! SyntaxInfo call s:get_syn_info()

" =============================================
" 本日の日付を曜日込みで挿入する
" ex.) # 2019/05/07(火)
" =============================================
function! s:insert_today()
    let today = system("date '+%Y/%m/%d(%a)'")
    " markdown用なのでシャープを先頭につける
    execute ':normal i# ' . today
endfunction
command! Today call s:insert_today()

" =============================================
" テスト用のtest.phpを新規タブで開く
" =============================================
function! s:open_test_php()
    execute ':tabnew ~/test.php'
endfunction
command! Testphp call s:open_test_php()

" =============================================
" テスト用のshellを新規タブで開く
" =============================================
function! s:open_test_shell()
    execute ':tabnew ~/test.sh'
endfunction
command! Testshell call s:open_test_shell()

" =============================================
" Terminalを開く
" =============================================
function! s:open_terminal_by_floating_window()
    " 空のバッファを作る
    let buf = nvim_create_buf(v:false, v:true)
    " そのバッファを使って floating windows を開く
    let height = float2nr(&lines * 0.5)
    let width = float2nr(&columns * 1.0)
    let horizontal = float2nr((&columns - width) / 2)
    let vertical = float2nr((&columns - height) / 2)
    let opts = {
        \ 'relative': 'editor',
        \ 'row': vertical,
        \ 'col': horizontal,
        \ 'width': width,
        \ 'height': height,
        \ 'anchor': 'NE',
    \}
    let g:win_id = nvim_open_win(buf, v:true, opts)
    set winblend=40
    terminal
    startinsert
endfunction
nnoremap T :call <SID>open_terminal_by_floating_window()<CR>

" =============================================
" READMEテンプレートを挿入
" =============================================
function! s:insert_template_github_readme()
    let template = "Name \r====\r\rOverview\r\r## Description\r\r## Demo\r\r## Requirement\r\r## Install\r\r## Usage"
    execute ':normal i' . template
endfunction
command! Readme call s:insert_template_github_readme()

" =============================================
" 英語のcommitメッセージ例文集を表示
" =============================================
function! s:show_commit_messages(str)
    call setline('.', a:str)
    " let command = 'cat ~/commit_messages_en.txt | grep ' . a:str
    " call fzf#run({
    " \ 'source': command,
    " \ 'sink'  : function('<SID>categorize_commit_messages'),
    " \ 'down'  : '40%'
    " \ })
endfunction
function! s:categorize_commit_messages(category)
    call setline('.', a:category)
endfunction
command! CommitMessages call fzf#run({
    \ 'source': 'cat ~/commit_messages_en.txt',
    \ 'sink'  : function('<SID>show_commit_messages'),
    \ 'down'  : '40%'
    \ })

" =============================================
" 選択範囲内の空行を削除
" =============================================
function! s:remove_empty_line() range
    execute ':' . a:firstline . ',' . a:lastline . 'g/^$/d'
endfunction
command! -range RemoveEmptyLine <line1>,<line2>call s:remove_empty_line()

" =============================================
" 選択範囲内の空白を削除
" =============================================
function! s:remove_space() range
    execute ':' . a:firstline . ',' . a:lastline . 's/\s\+$//ge'
    execute ':noh'
endfunction
command! -range RemoveSpace <line1>,<line2>call s:remove_space()

" =============================================
" 指定のデータをレジスタに登録する
" =============================================
function! s:Clip(data)
    let @*=substitute(a:data, $HOME.'/', '',  'g')
    echo "clipped: " . @*
endfunction
" 現在開いているファイルのパスをレジスタへ
command! -nargs=0 ClipPath call s:Clip(expand('%:p'))
" 現在開いているファイルのファイル名をレジスタへ
command! -nargs=0 ClipFile call s:Clip(expand('%:t'))
" memoを新しいタブで開く
command! Memo :tabe ~/memo.md

" =============================================
" Exコマンドの結果を別タブで開いて表示
" =============================================
function! s:show_ex_result(cmd)
  redir => message
  silent execute a:cmd
  redir END
  if empty(message)
    echoerr "no output"
  else
    tabnew
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted nomodified
    silent put=message
  endif
endfunction
command! -nargs=+ -complete=command ShowExResult call s:show_ex_result(<q-args>)

" =============================================
" vimrcに関わるファイルをfzfで表示する
" `vimrc`コマンドをvim上で実現するもの
" =============================================
function! s:fzf_vimrc()
  call fzf#run({
    \ 'source': "find ~/dotfiles ${XDG_CONFIG_HOME}/nvim/myautoload -follow -name '*.vim' -o -name 'dein.toml' -o -name 'xvimrc' | awk '{ print length, $0 }' | sort -n -s | cut -d' ' -f2- ",
    \ 'sink': 'tabe',
    \ 'down': '40%',
    \ 'options': '--preview "bat --color always {} --style=plain | head -n 100"'
    \ })
endfunction
command! Vimrc call s:fzf_vimrc()

" =============================================
" zshrcに関わるファイルをfzfで表示する
" `zshrc`コマンドをvim上で実現するもの
" =============================================
function! s:fzf_zshrc()
  call fzf#run({
    \ 'source': "find ~/dotfiles/zsh -type f | awk '{ print length, $0 }' | sort -n -s | cut -d' ' -f2- ",
    \ 'sink': 'tabe',
    \ 'down': '40%',
    \ 'options': '--preview "bat --color always {} --style=plain | head -n 100"'
    \ })
endfunction
command! Zshrc call s:fzf_zshrc()

" =============================================
" コマンドの結果を取得する
" @see http://koturn.hatenablog.com/entry/2015/07/31/001507
" =============================================
function! s:get_command_result(cmd) abort
  let [verbose, verbosefile] = [&verbose, &verbosefile]
  set verbose=0 verbosefile=
  redir => str
    execute 'silent!' a:cmd
  redir END
  let [&verbose, &verbosefile] = [verbose, verbosefile]
  return str
endfunction

" =============================================
" :messagesの最後の行を取得する
" =============================================
function! s:get_last_message() abort
  let lines = filter(split(s:get_command_result('messages'), "\n"), 'v:val !=# ""')
  if len(lines) <= 0
      return ''
  end
  return lines[len(lines) - 1 :][0]
endfunction
command! MessageLast call s:get_last_message()

" Rasukarusan/popup_message.nvimの関数
nnoremap <silent> MM :call popup_message#open(<SID>get_last_message())<CR>

" =============================================
" :messagesの最後の行をコピーする
" =============================================
function! s:copy_last_message()
    let lastMessage = s:get_last_message()
    if strlen(lastMessage) <= 0
        echo 'メッセージがありません'
        return
    end
    let @*=lastMessage
    echo 'clipped: ' . @*[:20] . '...'
endfunction
command! CopyLastMessage call s:copy_last_message()

" =============================================
" jsxでコメントアウト開始/終了を差し込む
" =============================================
function! s:comment_out_jsx() range
    " 下記2行でも実現可能だが、置換した旨がechoされてしまい邪魔なのでfor文でしている。silentでも消えない。
    " execute ':'.a:firstline.','.a:lastline.' s/\(\S\)/{\/* \1/'
    " execute ':'.a:firstline.','.a:lastline.' s/$/ *\/}/'
    for currentLineNo in range(a:firstline, a:lastline)
        " 指定した行を取得
        let currentLine = getline(currentLineNo)
        let isComment = stridx(currentLine, '{/*')
        if isComment != -1
            execute ':'.currentLineNo.' s/{\/\* //'
            execute ':'.currentLineNo.' s/ \*\/}//'
        else
            execute ':'.currentLineNo.' s/\(\S\)/{\/* \1/'
            execute ':'.currentLineNo.' s/$/ *\/}/'
        endif
    endfor
endfunction
command! -range CommentOut <line1>,<line2>call s:comment_out_jsx()
nnoremap Com :CommentOut<CR>
vnoremap Com :CommentOut<CR>


" =============================================
" shellコマンドを実行
" @See https://vim.fandom.com/wiki/Display_output_of_shell_commands_in_new_window
" =============================================
function! s:exec_shell_command(cmdline)
  let expanded_cmdline = a:cmdline
  for part in split(a:cmdline, ' ')
     if part[0] =~ '\v[%#<]'
        let expanded_part = fnameescape(expand(part))
        let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
     endif
  endfor
  botright new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  execute '0read !'. expanded_cmdline
  setlocal nomodifiable
  1 " カーソルを先頭へ移動
endfunction
command! -complete=shellcmd -nargs=+ Shell call s:exec_shell_command(<q-args>)

" =============================================
" Exコマンドの補完をfzfでする
" =============================================
function! CompletionExCmdWithFzf()
    let currentCmdLine = getcmdline()
    let isVisualMode = stridx(currentCmdLine, "'<,'>") != -1
    let isCall = stridx(currentCmdLine, 'call ') != -1
    let type = 'command'
    let prefix = ''

    if isCall == 1
      let cmdLines = split(currentCmdLine, ' ')
      let currentCmdLine = len(cmdLines) > 1 ? cmdLines[1] : ''
      let type = 'function'
      let prefix = 'call '
    elseif isVisualMode == 1
      let cmdLines = split(currentCmdLine, '>')
      let currentCmdLine = len(cmdLines) > 1 ? cmdLines[1] : ''
      let type = 'command'
      let prefix = "'<,'>"
    endif

    let result = fzf#run({
      \'source': getcompletion(currentCmdLine, type),
      \ 'tmux': '-p60%,60%',
      \ 'options': '--no-multi --bind tab:down'
      \}
    \)
    if len(result) == 0
      return ''
    endif

    " fzf#runの結果はlist型で返されるので、そのままコマンドラインに返すと^@が末尾に付与される
    " ^@を削除するためjoin()している
    return prefix . join(result, '')
endfunction
" cnoremap <TAB> <C-\>eCompletionExCmdWithFzf()<CR>

" =============================================
" 別ブランチのファイルを開く
" =============================================
function! s:open_file_of_branch(branch, file)
  execute ':Gtabedit '.a:branch.':'.a:file
endfunction

" =============================================
" 別ブランチのファイル一覧をfzfで表示して開く
" =============================================
function! s:fzf_show_git_files(branch)
  call fzf#run({
    \ 'source': 'git ls-tree -r --name-only ' . a:branch,
    \ 'sink': function('s:open_file_of_branch', [a:branch]),
    \ 'tmux': '-p60%,60%',
    \ })
endfunction

" =============================================
" ブランチ一覧を表示しファイルを選択して表示する
" =============================================
function! s:fzf_show_branch(...)
  if a:0 == 1
    call <SID>fzf_show_git_files(a:1)
  else
    call fzf#run({
      \ 'source': 'git branch -a',
      \ 'sink': function('s:fzf_show_git_files'),
      \ 'tmux': '-p60%,60%',
      \ })
  endif
endfunction
command! -nargs=? Cof call s:fzf_show_branch(<f-args>)

" =============================================
" カレントディレクトリをfzfで変更
" =============================================
function! s:fzf_cd()
  let excludeDirs = ['node_modules', '.git']
  let excludeCmd = ''
  for excludeDir in excludeDirs
    let excludeCmd = excludeCmd . ' -type d -name ' . excludeDir . ' -prune -o'
  endfor
  call fzf#run({
    \ 'source': 'find . $(git rev-parse --show-cdup) ' . excludeCmd . ' -type d',
    \ 'sink': 'cd',
    \ 'tmux': '-p60%,60%',
    \ })
endfunction
command! Cdd call s:fzf_cd()

" =============================================
" カレントバッファより後ろのバッファを全て削除
" =============================================
function! s:delete_all_buffers()
  let buffer_count = bufnr('$')
  if buffer_count > 1
    execute ':.+,$bwipeout'
  endif
endfunction
nnoremap <silent> BB :call <SID>delete_all_buffers()<CR>
