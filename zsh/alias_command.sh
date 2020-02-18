# ============================== #
#         alias-Command          #
# ============================== #
alias l='ls -ltrG'
alias la='ls -laG'
alias laa='ls -ld .*'
alias ll='ls -lG'
alias ls='ls -G'
alias lh='ls -lh'
alias grep='grep --color=auto'
alias ...='cd ../../'
alias ....='cd ../../../'
alias history='history 1'
alias his='eval $(\history 1 | cut -d " " -f 3- | tail -r | fzf)'
alias time='/usr/bin/time -p'
alias ssh='TERM=xterm ssh'
# treeコマンドで日本語表示
alias tree='tree --charset=C -NC'
alias szsh='source ~/.zshrc'
alias stmux='tmux source-file ~/.tmux.conf'
alias tconf='vim ~/.tmux.conf'
alias hp='vim ~/.hyper.js'
alias plantuml='java -jar ~/.plantuml/plantuml.jar'
alias grepr='grep -r'
alias phpS='php -S localhost:9000'
alias phps='hyper-run -s localhost:9000 -t .'
alias js='osascript -l JavaScript'
# terminalの描画がおかしいときにそれも直してclearする
alias clear='stty sane;clear'
alias gd='git diff -b'
alias gdc='git diff -b --cached'
# 現在のブランチをpullする
alias -g gpl='git pull --rebase origin $(git branch | grep "*" | sed -e "s/^\*\s*//g")'
alias repoo='vim `ls ~/Desktop/ru-she-1nian-mu/DayReport/*.md | fzf`'
alias memo='vim ~/Desktop/ru-she-1nian-mu/memo.md -c ":$"'
# git checkout branchをfzfで選択
alias co='git checkout $(git branch -a | tr -d " " |fzf --height=100% --prompt "CHECKOUT BRANCH>" --preview "git log --color=always {}" | head -n 1 | sed -e "s/^\*\s*//g" | perl -pe "s/remotes\/origin\///g")'
alias co-='git checkout -'
alias gst='git status'
alias gv='git remote -v'
# 全てのファイルをgit checkout
alias gca='git checkout $(git diff --name-only)'
# ctagsをbrew installしたものを使う
alias ctags='$(brew --prefix)/bin/ctags'
# コマンドでgoogle翻訳
alias trans='trans -b en:ja'
alias transj='trans -b ja:en'
# 対象のDBでカラム名を検索
alias getTable='cat ~/result.txt | tgrep "SELECT * FROM " " WHERE"'
# Docコメントの"*"を削除してダブルクォートで囲む
alias deled='(echo -n \" ; pbpaste | sed "s/*//g" ; echo -n \")'
# ブラウザからコピーした時など、プレーンテキストに戻したい時に使用
alias pcopy='pbpaste | pbcopy'
# スプレッドシートから表をコピーしてRedmineのテーブル形式に整形したい時に使用(先頭と末尾に|を挿入,タブを|に置換)
alias rtable='pbpaste | tr "\t" "|" | sed -e "s/^/|/g" -e "s/$/|/g" -e "/|\"/s/|$//g" -e "/\"|/s/^|//g" | tr -d \" | pbcopy'
# modifiedのファイルを全てタブで開く
alias vims='vim -p `git diff --name-only`'
# Unite tabでコピーしたものをタブで開く
alias vimt="vim -p `pbpaste | sed 's/(\/)//g' | awk -F ':' '{print $2}' | grep -v '\[' | tr '\n' ' '`"
# 合計値を出す。列が一つのときのみ有効
alias tsum='awk "{sum += \$1}END{print sum}"'
# 最終更新日が一番新しいもののファイル名を取得
alias fin='echo `ls -t | head -n 1`'
# less `fin`と打つのが面倒だったため関数化。finはコマンドとして残しておきたいので残す
alias late='less $(echo `ls -t | head -n 1`)'
# 現在のブランチの番号のみを取得してコピーする
alias gget="git rev-parse --abbrev-ref HEAD | grep -oP '[0-9]*' | tr -d '\n' | pbcopy;pbpaste"
# 空行を削除
alias demp='sed "/^$/d"'
# 一時ファイル作成エイリアス
alias p1='pbpaste > ~/p1'
alias p2='pbpaste > ~/p2'
alias p1e='vim ~/p1'
alias p2e='vim ~/p2'
alias pd='vimdiff ~/p1 ~/p2'
alias pst='pstree | less -S'
alias oo='open .'
alias hosts='sudo vim /etc/hosts'
alias dekita='afplay ~/Music/iTunes/iTunes\ Media/Music/Unknown\ Artist/Unknown\ Album/dekita.mp3'
alias chen='afplay ~/Music/iTunes/iTunes\ Media/Music/Unknown\ Artist/Unknown\ Album/jacky_chen.mp3'
alias mailque='postqueue -p'
alias maildel='sudo postsuper -d ALL deferred'
# YYYY/mm/dd(曜日)形式で本日を出力
alias today="date '+%Y/%m/%d(%a)'" 
# クリップボードの行数を出力
alias wcc='pbpaste | grep -c ^'
# vimをvimrcなし, プラグインなしで起動する
# NONEにvimrcのPATHを入れれば読み込むことができる
alias vimn='vim -u NONE -N'
alias pbp='pbpaste'
alias pbc='pbcopy'
# グローバルIPを確認
alias myip='curl ifconfig.io'
alias xcode-restore='update_xcode_plugins --restore'
alias xcode-unsign='update_xcode_plugins --unsign'
alias copyMinVimrc='cat ~/dotfiles/min_vimrc | grep -v "\"" | pbcopy'
alias copyMinBashrc='cat ~/dotfiles/min_bashrc | grep -v "#" | pbcopy'
# wifiをON/OFFする
alias wifiConnect='networksetup -setairportpower en0 off && networksetup -setairportpower en0 on'
# printfの色出力を一覧表示
alias printColors='for fore in `seq 30 37`; do printf "\e[${fore}m \\\e[${fore}m \e[m\n"; for mode in 1 4 5; do printf "\e[${fore};${mode}m \\\e[${fore};${mode}m \e[m"; for back in `seq 40 47`; do printf "\e[${fore};${back};${mode}m \\\e[${fore};${back};${mode}m \e[m"; done; echo; done; echo; done; printf " \\\e[m\n"'
alias sshadd='ssh-add ~/.ssh/id_rsa'
# FortClientはMacの上部バーから終了する際、一々パスワードを求めてくるのでkillが楽
alias fortKill="ps aux | grep 'Fort' | awk '{print \$2}' | xargs kill"
# metabase起動。起動後しばらくしたらhttp://localhost:3300でアクセスできる
alias metabase-run='docker run -d -p 3300:3000 -v /tmp:/tmp -e "MB_DB_FILE=/tmp/metabase.db" --name metabase metabase/metabase'
# Redemineのテンプレート文言をvimで開く
alias redmine_template='vim $(mktemp XXXXXXXXXX) -c ":read! cat ~/redmine_template.txt"'
