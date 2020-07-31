bindkey -e # ctrl-aやctrl-eでカーソル移動
# zshのTab補完
autoload -U compinit && compinit
# テーマ読み込み
source ~/dotfiles/zsh/zsh-my-theme.zsh
# Tabで選択できるように
zstyle ':completion:*:default' menu select=2
# 補完で大文字にもマッチ
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# ファイル補完候補に色を付ける
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
setopt auto_param_slash       # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs              # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt auto_menu              # 補完キー連打で順に補完候補を自動で補完
setopt interactive_comments   # コマンドラインでも # 以降をコメントと見なす
setopt magic_equal_subst      # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
setopt complete_in_word       # 語の途中でもカーソル位置で補完
setopt print_eight_bit        # 日本語ファイル名等8ビットを通す
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt share_history          # 他のターミナルとヒストリーを共有
setopt histignorealldups      # ヒストリーに重複を表示しない
setopt hist_save_no_dups      # 重複するコマンドが保存されるとき、古い方を削除する。
setopt extended_history       # $HISTFILEに時間も記録
setopt print_eight_bit        # 日本語ファイル名を表示可能にする
setopt hist_ignore_all_dups   # 同じコマンドをヒストリに残さない
setopt auto_cd                # ディレクトリ名だけでcdする
setopt no_beep                # ビープ音を消す
# コマンドを途中まで入力後、historyから絞り込み
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
# 特定のコマンドのみ履歴に残さない
zshaddhistory() {
    local line=${1%%$'\n'}
    local cmd=${line%% *}
    # 以下の条件をすべて満たすものだけをヒストリに追加する
    [[ ${#line} -ge 5
        && ${cmd} != (l|l[sal]$) # l,ls,la,ll
        && ${cmd} != (c|cd)
        && ${cmd} != (fg|fgg)
    ]]
}
# cdrの設定
autoload -Uz is-at-least
if is-at-least 4.3.11
then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':chpwd:*'      recent-dirs-max 500
    zstyle ':chpwd:*'      recent-dirs-default yes
    zstyle ':chpwd:*'      recent-dirs-file "$HOME/.cache/cdr/history"
    zstyle ':completion:*' recent-dirs-insert both
fi

# 自作Snippet
show_snippets() {
    local snippets=$(cat ~/zsh_snippet | fzf | cut -d':' -f2-)
    LBUFFER="${LBUFFER}${snippets}"
    zle reset-prompt
}
zle -N show_snippets
bindkey '^o' show_snippets

# 現在行をvimで編集して実行する
edit_current_line() {
    local tmpfile=$(mktemp)
    echo "$BUFFER" > $tmpfile
    vim $tmpfile -c "normal $" -c "set filetype=zsh"
    BUFFER="$(cat $tmpfile)"
    CURSOR=${#BUFFER}
    rm $tmpfile
    zle reset-prompt
}
zle -N edit_current_line
bindkey '^w' edit_current_line
