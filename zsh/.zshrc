# ============================================================================
# ZSH Configuration File
# ============================================================================
#
# Dependencies Required:
#   Core: zsh, git
#   Essential: fzf, starship, zoxide, wl-clipboard
#   Optional: bat, eza, delta, fd, rg, dust, duf, procs, btm, hyperfine, tokei
#   Tools: nvim, lazygit, lazydocker, yazi, docker
#
# ============================================================================

# PATH Configuration
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# ============================================================================
# Zinit Plugin Manager Setup
# ============================================================================

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

ZINIT[OPTIMIZE_OUT_DISK_ACCESSES]=1

# Annexes must load before plugins
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# ============================================================================
# Zinit Plugins (Turbo mode - deferred load)
# ============================================================================
# Load order: completions/autosuggestions → snippets → syntax-highlighting
# → history-substring-search. fsh must come AFTER autosuggestions, and
# history-substring-search AFTER fsh, otherwise widgets wrap incorrectly.

export ZSH_AUTOSUGGEST_STRATEGY=history
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

zinit ice wait lucid nocd atload"_zsh_autosuggest_start" silent
zinit light zsh-users/zsh-autosuggestions

zinit ice wait lucid blockf atpull'zinit creinstall -q .' silent
zinit light zsh-users/zsh-completions

zinit ice wait lucid silent
zinit light hlissner/zsh-autopair

zinit ice wait lucid silent
zinit light MichaelAquilina/zsh-you-should-use

zinit ice wait lucid silent
zinit snippet OMZ::plugins/colored-man-pages/colored-man-pages.plugin.zsh

zinit ice wait lucid silent
zinit snippet OMZ::lib/clipboard.zsh

zinit ice wait lucid silent
zinit snippet OMZ::lib/git.zsh

zinit ice wait lucid nocd atinit"zicompinit; zicdreplay" silent
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait lucid nocd atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" silent
zinit light zsh-users/zsh-history-substring-search

# ============================================================================
# History Configuration
# ============================================================================

HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE

setopt share_history          # implies inc_append_history
setopt extended_history       # store timestamp + duration with each entry
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_verify            # show recalled commands before executing

# ============================================================================
# Completion System
# ============================================================================

zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
zstyle ':completion:*' menu no
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true

[ ! -d "$HOME/.zsh/cache" ] && mkdir -p "$HOME/.zsh/cache"

if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
    zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
fi

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# ============================================================================
# Shell Options
# ============================================================================

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt interactive_comments
setopt multios
setopt prompt_subst
setopt no_beep
setopt extended_glob          # **/*, qualifiers, alternation

# ============================================================================
# Aliases
# ============================================================================

# Cat replacement with bat
alias cat='bat'
alias catn='bat --style=plain'
alias catnp='bat --style=plain --paging=never'

# Editor
alias v='nvim'
alias vim='nvim'
alias vi='nvim'
alias code='codium'

# Git
alias gcl='git clone --depth 1'
alias gi='git init'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit -am'
alias gp='git push'
alias gpl='git pull'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gb='git branch'

# Terminal tools
alias lg='lazygit'
alias ld='lazydocker'
alias y='yazi'
alias neofetch='fastfetch -c examples/8'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Directory shortcuts
alias dl='cd ~/Downloads'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'

# Safe file operations
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -I'   # -I only prompts when removing >3 files or recursively

# Package manager (Arch Linux) — prefixed to avoid clobbering coreutils 'install'
alias pacu='sudo pacman -Syu'
alias paci='sudo pacman -S'
alias pacs='pacman -Ss'
alias pacr='sudo pacman -Rns'
alias pacq='pacman -Qi'

# AI assistants
alias opc='opencode'
alias pass='pass-cli'

# Modern tool replacements (conditional)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --group-directories-first'
    alias la='eza -a --icons --group-directories-first'
    alias lla='eza -lha --icons --group-directories-first'
    alias lt='eza --tree --icons --group-directories-first'
fi
command -v duf   &>/dev/null && alias df='duf'
command -v procs &>/dev/null && alias psr='procs'   # 'ps' kept as POSIX for scripts
command -v btm   &>/dev/null && alias top='btm'
if command -v docker &>/dev/null; then
    alias dpsa='docker ps -a'
    alias di='docker images'
    alias dfe='dce'  # fuzzy interactive exec (fzf)
fi

# Function shortcuts
alias gch='gcof'
alias gchr='gcor'
alias gst='gstash'
alias hf='fh'
alias rf='rgf'
alias pv='preview'
alias mon='monitor'
alias du='diskusage'
alias dsk='disks'
alias bm='bench'
alias cstat='codestats'
alias pf='psef'
alias dt='dtree'   # don't shadow the real 'tree' binary

# ============================================================================
# Functions
# ============================================================================

# Secure file removal
rmk() {
    if [ -z "$1" ]; then
        echo "Usage: rmk <file>"
        return 1
    fi
    if command -v scrub &>/dev/null; then
        scrub -p dod "$1"
    fi
    shred -zun 10 -v "$1"
}

# Extract various archive formats
extract() {
    if [ -z "$1" ]; then
        echo "Usage: extract <archive>"
        return 1
    fi
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"         ;;
            *.tar.gz)    tar xzf "$1"         ;;
            *.tar.xz)    tar xJf "$1"         ;;
            *.tar.zst)   tar --zstd -xf "$1"  ;;
            *.bz2)       bunzip2 "$1"         ;;
            *.rar)       unrar x "$1"         ;;
            *.gz)        gunzip "$1"          ;;
            *.tar)       tar xf "$1"          ;;
            *.tbz2)      tar xjf "$1"         ;;
            *.tgz)       tar xzf "$1"         ;;
            *.zip)       unzip "$1"           ;;
            *.Z)         uncompress "$1"      ;;
            *.7z)        7z x "$1"            ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Make directory and cd into it
mkcd() {
    if [ -z "$1" ]; then
        echo "Usage: mkcd <directory>"
        return 1
    fi
    mkdir -p "$1" && cd "$1"
}

# Backup file with timestamp
backup() {
    if [ -z "$1" ]; then
        echo "Usage: backup <file>"
        return 1
    fi
    cp "$1"{,.bak-$(date +%Y%m%d-%H%M%S)}
}

# Fuzzy find and edit file
vf() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local file
    file=$(fzf --preview 'bat --color=always --style=full --line-range=:500 {}' \
               --preview-window='right:60%:wrap' \
               --header='Select file to edit' \
               --border=rounded \
               --height=90%)
    [ -n "$file" ] && nvim "$file"
}

# Fuzzy find directory with zoxide
zf() {
    if ! command -v zoxide &>/dev/null; then
        echo "Error: zoxide is required. Install with: sudo pacman -S zoxide"
        return 1
    fi
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local dir
    dir=$(zoxide query -l | fzf \
        --preview 'eza --color=always --icons=always --tree --level=2 {} 2>/dev/null || ls -la {}' \
        --preview-window='right:60%:wrap' \
        --header='Jump to directory' \
        --border=rounded \
        --height=90%)
    [ -n "$dir" ] && cd "$dir"
}

# Fuzzy git branch checkout
gcof() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local branch
    branch=$(git branch --all 2>/dev/null | grep -v HEAD |
             sed 's/^[* ]*//' | sed 's#remotes/origin/##' |
             sort -u |
             fzf --preview 'git log --oneline --graph --color=always --date=short --pretty="format:%C(auto)%h %C(blue)%an %C(green)%ar %C(auto)%s" {} 2>/dev/null | head -50' \
                 --preview-window='right:70%:wrap' \
                 --header='Checkout branch (Ctrl-Y to copy)' \
                 --border=rounded \
                 --height=90% \
                 --bind='ctrl-y:execute-silent(echo -n {} | wl-copy)+abort')
    [ -n "$branch" ] && git checkout "$branch"
}

# Fuzzy process kill
kp() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local signal=${1:-9}
    local pids
    pids=$(ps -ef | sed 1d |
           fzf -m --header="Select process to kill (Signal: $signal, TAB for multi)" \
               --preview 'echo {}' \
               --preview-window=down:3:wrap \
               --border=rounded \
               --height=50% |
           awk '{print $2}')
    if [ -n "$pids" ]; then
        echo "$pids" | xargs -r kill -"${signal}"
        echo "Killed process(es): $pids"
    fi
}

# Find and cd to directory
fd-cd() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local dir
    if command -v fd &>/dev/null; then
        dir=$(fd --type d --hidden --follow --exclude .git |
              fzf --preview 'eza --color=always --icons=always --tree --level=2 {} 2>/dev/null || ls -la {}' \
                  --header='Find and cd to directory' \
                  --border=rounded \
                  --height=70%)
    else
        dir=$(find . -type d -name '.git' -prune -o -type d -print 2>/dev/null |
              fzf --preview 'eza --color=always --icons=always --tree --level=2 {} 2>/dev/null || ls -la {}' \
                  --header='Find and cd to directory' \
                  --border=rounded \
                  --height=70%)
    fi
    [ -n "$dir" ] && cd "$dir"
}

# Fuzzy git add files
gaf() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local files
    local preview_cmd='git diff --color=always {2}'
    if command -v delta &>/dev/null; then
        preview_cmd='git diff --color=always {2} | delta'
    fi
    files=$(git status --short |
            fzf -m --preview "$preview_cmd" \
                --preview-window='right:70%:wrap' \
                --header='Select files to stage (TAB for multi)' \
                --border=rounded \
                --height=90% \
                --bind='ctrl-a:select-all' \
                --bind='ctrl-d:deselect-all' \
                --bind='ctrl-t:toggle-all' |
            awk '{print $2}')
    if [ -n "$files" ]; then
        echo "$files" | xargs git add
        print "\nStaged files:"
        echo "$files" | sed 's/^/  /'
        echo ""
        git status --short
    fi
}

# Ripgrep fuzzy search
rgf() {
    if ! command -v rg &>/dev/null; then
        echo "Error: ripgrep is required. Install with: sudo pacman -S ripgrep"
        return 1
    fi
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local preview_cmd='bat --color=always --highlight-line {2} {1}'
    if ! command -v bat &>/dev/null; then
        preview_cmd='cat {1}'
    fi
    local selected
    selected=$(rg --color=always --line-number --no-heading --smart-case "${*:-}" |
               fzf --ansi \
                   --delimiter : \
                   --preview "$preview_cmd" \
                   --preview-window 'up,60%,border-rounded,+{2}+3/3,~3' \
                   --header='Search in code' \
                   --border=rounded \
                   --height=90%)
    if [ -n "$selected" ]; then
        local file line
        file=$(echo "$selected" | cut -d: -f1)
        line=$(echo "$selected" | cut -d: -f2)
        nvim "+$line" "$file"
    fi
}

# Fuzzy command history
fh() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local cmd
    cmd=$(fc -l 1 | fzf --tac --no-sort \
                        --preview 'echo {}' \
                        --preview-window=down:3:wrap \
                        --header='Command history (Enter to execute, Ctrl-Y to copy)' \
                        --border=rounded \
                        --height=50% \
                        --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort' |
          sed 's/^ *[0-9]* *//')
    [ -n "$cmd" ] && print -z "$cmd"
}

# Git stash manager
gstash() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local preview_cmd='git stash show -p $(echo {} | cut -d: -f1)'
    if command -v delta &>/dev/null; then
        preview_cmd='git stash show -p $(echo {} | cut -d: -f1) | delta'
    fi
    local stash
    stash=$(git stash list |
            fzf --preview "$preview_cmd" \
                --preview-window='right:70%:wrap' \
                --header='Select stash (Enter to apply, Ctrl-D to drop)' \
                --border=rounded \
                --height=90% \
                --bind='ctrl-d:execute(git stash drop $(echo {} | cut -d: -f1))+reload(git stash list)')
    [ -n "$stash" ] && git stash pop "$(echo "$stash" | cut -d: -f1)"
}

# Preview file with bat
preview() {
    if ! command -v bat &>/dev/null; then
        echo "Error: bat is required. Install with: sudo pacman -S bat"
        return 1
    fi
    local file="$1"
    if [ -z "$file" ]; then
        if ! command -v fzf &>/dev/null; then
            echo "Error: fzf is required. Install with: sudo pacman -S fzf"
            return 1
        fi
        file=$(fzf --preview 'bat --color=always --style=full {}' \
                   --preview-window='right:70%:wrap' \
                   --header='Preview file' \
                   --border=rounded \
                   --height=90%)
    fi
    [ -n "$file" ] && bat --paging=always "$file"
}

# Git checkout recent branches
gcor() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local branch
    branch=$(git reflog |
             grep 'checkout:' |
             sed 's/.* to //' |
             awk '!seen[$0]++' |
             head -20 |
             fzf --preview 'git log --oneline --graph --color=always --date=short {} | head -50' \
                 --preview-window='right:70%:wrap' \
                 --header='Recent branches' \
                 --border=rounded \
                 --height=70%)
    [ -n "$branch" ] && git checkout "$branch"
}

# Docker container exec
dce() {
    if ! command -v docker &>/dev/null; then
        echo "Error: docker is required. Install with: sudo pacman -S docker"
        return 1
    fi
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local container
    container=$(docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.Image}}' |
                fzf --header='Select container (Enter to exec bash)' \
                    --preview 'docker logs --tail 100 $(echo {} | cut -f1)' \
                    --preview-window='right:60%:wrap' \
                    --border=rounded \
                    --height=70%)
    [ -n "$container" ] && docker exec -it "$(echo "$container" | cut -f1)" bash
}

# System monitor
monitor() {
    if command -v btm &>/dev/null; then
        btm
    elif command -v htop &>/dev/null; then
        htop
    else
        top
    fi
}

# Disk usage analyzer
diskusage() {
    local dir="${1:-.}"
    if command -v dust &>/dev/null; then
        dust -r "$dir"
    else
        du -h "$dir" | sort -hr | head -20
    fi
}

# Compare disk usage of two directories
diskcompare() {
    if command -v dust &>/dev/null; then
        echo "=== Directory 1: ${1:-.} ==="
        dust -r -d 1 "${1:-.}"
        echo ""
        echo "=== Directory 2: ${2:-.} ==="
        dust -r -d 1 "${2:-.}"
    else
        echo "Error: dust is required. Install with: sudo pacman -S dust"
    fi
}

# Benchmark command execution
bench() {
    if command -v hyperfine &>/dev/null; then
        hyperfine --warmup 3 "$@"
    else
        echo "Error: hyperfine is required. Install with: sudo pacman -S hyperfine"
    fi
}

# Code statistics
codestats() {
    if command -v tokei &>/dev/null; then
        tokei "${1:-.}" --sort lines
    else
        echo "Error: tokei is required. Install with: sudo pacman -S tokei"
    fi
}

# Process selector with kill option
psef() {
    if command -v procs &>/dev/null; then
        if ! command -v fzf &>/dev/null; then
            echo "Error: fzf is required. Install with: sudo pacman -S fzf"
            return 1
        fi
        local pid
        pid=$(procs | tail -n +2 |
              fzf --header='Select process (Enter to kill)' \
                  --preview 'echo {}' \
                  --preview-window=down:3:wrap \
                  --border=rounded \
                  --height=70% |
              awk '{print $1}')
        if [ -n "$pid" ]; then
            echo "Kill process $pid? (y/n)"
            read -q && kill -15 "$pid" && print "\nProcess $pid terminated"
        fi
    else
        kp
    fi
}

# Fuzzy file finder
ff() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required. Install with: sudo pacman -S fzf"
        return 1
    fi
    local preview_cmd='bat --color=always --style=numbers --line-range=:100 {}'
    if ! command -v bat &>/dev/null; then
        preview_cmd='head -100 {}'
    fi
    local file
    if command -v fd &>/dev/null; then
        file=$(fd --type f --hidden --follow --exclude .git |
               fzf --preview "$preview_cmd" \
                   --preview-window='right:60%:wrap' \
                   --header='Find file' \
                   --border=rounded \
                   --height=80%)
    else
        file=$(find . -type f -not -path '*/\.git/*' 2>/dev/null |
               fzf --preview "$preview_cmd" \
                   --preview-window='right:60%:wrap' \
                   --header='Find file' \
                   --border=rounded \
                   --height=80%)
    fi
    [ -n "$file" ] && echo "$file"
}

# Directory tree viewer
dtree() {
    local depth="${1:-2}"
    if command -v eza &>/dev/null; then
        eza --tree --level="$depth" --icons --git-ignore
    elif command -v tree &>/dev/null; then
        command tree -L "$depth" -I '.git'
    else
        echo "Error: Install eza or tree. Recommended: sudo pacman -S eza"
    fi
}

# List files with git status
lsg() {
    if command -v eza &>/dev/null; then
        eza --long --git --icons --group-directories-first --header
    else
        ls -lah
    fi
}

# List files sorted by size
lss() {
    if command -v eza &>/dev/null; then
        eza --long --all --sort=size --reverse --icons --group-directories-first
    else
        ls -lhS
    fi
}

# List files sorted by modification time
lst() {
    if command -v eza &>/dev/null; then
        eza --long --all --sort=modified --reverse --icons --group-directories-first
    else
        ls -lht
    fi
}

# Disk space analyzer
disks() {
    if command -v duf &>/dev/null; then
        duf
    else
        df -h
    fi
}

# Quick help viewer — don't shadow zsh's 'help' / run-help builtin
tl() {
    if command -v tldr &>/dev/null; then
        tldr "$@"
    else
        man "$@"
    fi
}

# ProtonPass: search and view item across vaults
# Required in ~/.env: PROTONPASS_PERSONAL and PROTONPASS_WORK (vault IDs)
pfind() {
    if [ -z "$PROTONPASS_PERSONAL" ] || [ -z "$PROTONPASS_WORK" ]; then
        echo "Error: Set PROTONPASS_PERSONAL and PROTONPASS_WORK in ~/.env"
        return 1
    fi

    local item_id
    item_id=$(pass item list "Personal" 2>/dev/null | grep -i "$1" | head -1 | awk -F'[][]' '{print $2}')

    if [ -n "$item_id" ]; then
        pass item view "pass://${PROTONPASS_PERSONAL}/${item_id}"
        return
    fi

    item_id=$(pass item list "Work" 2>/dev/null | grep -i "$1" | head -1 | awk -F'[][]' '{print $2}')

    if [ -n "$item_id" ]; then
        pass item view "pass://${PROTONPASS_WORK}/${item_id}"
        return
    fi

    echo "No se encontró item con: $1"
}

# ============================================================================
# Environment Variables
# ============================================================================

[ -f ~/.env ] && source ~/.env

export LS_COLORS="rs=0:di=37:ln=01;04;90:mh=00:pi=33:so=01;35:bd=33;01:cd=33;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32"

export EDITOR='nvim'
export VISUAL='nvim'

# FZF Configuration
export FZF_DEFAULT_OPTS="--height 60% --layout=reverse --border=rounded \
  --preview-window=right:50%:wrap \
  --bind='ctrl-/:toggle-preview' \
  --bind='ctrl-u:preview-half-page-up' \
  --bind='ctrl-d:preview-half-page-down' \
  --bind='ctrl-f:preview-page-down' \
  --bind='ctrl-b:preview-page-up' \
  --bind='ctrl-a:select-all' \
  --bind='ctrl-t:toggle-all' \
  --bind='ctrl-y:execute-silent(echo -n {+} | wl-copy)' \
  --bind='alt-up:preview-up' \
  --bind='alt-down:preview-down' \
  --color=fg:#c0caf5,bg:#1a1b26,hl:#7aa2f7 \
  --color=fg+:#c0caf5,bg+:#1f2335,hl+:#7dcfff \
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a \
  --color=border:#565f89,preview-bg:#1a1b26 \
  --pointer='▶' --marker='✓' --prompt='❯ ' \
  --info=inline"

if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --color=never'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --color=never'
elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# ============================================================================
# Key Bindings
# ============================================================================

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

foreground-current-job() { fg; }
zle -N foreground-current-job
bindkey '^Z' foreground-current-job

# ^F shadows forward-char (rarely used in emacs mode); kept for convenience.
open-file-finder() { zle -I; vf; zle reset-prompt; }
zle -N open-file-finder
bindkey '^F' open-file-finder

# ^O instead of ^G — ^G is the zsh send-break (abort) and shouldn't be reused.
open-dir-finder() { zle -I; zf; zle reset-prompt; }
zle -N open-dir-finder
bindkey '^O' open-dir-finder

# ============================================================================
# Safety Hook: Prevent Starship from capturing Zinit plugin directories
# ============================================================================

autoload -Uz add-zsh-hook

_ensure_correct_directory() {
    case "$PWD" in
        */.local/share/zinit/plugins/*|*/.local/share/zinit/snippets/*)
            builtin cd "$HOME" 2>/dev/null || true
            ;;
    esac
}

add-zsh-hook precmd _ensure_correct_directory

# ============================================================================
# Tool Initializations
# ============================================================================

command -v fzf      &>/dev/null && source <(fzf --zsh)
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v fnm      &>/dev/null && eval "$(fnm env --use-on-cd --shell zsh)"
command -v zoxide   &>/dev/null && eval "$(zoxide init zsh)"

# ============================================================================
# External Integrations
# ============================================================================

# Kitty: maintain working directory across new windows/tabs
if [[ "$TERM" == "xterm-kitty" ]]; then
    _kitty_set_working_directory() {
        printf '\e]7;kitty-shell-cwd://%s%s\a' "$HOSTNAME" "$PWD"
    }
    add-zsh-hook precmd _kitty_set_working_directory
    _kitty_set_working_directory
fi

[ -f ~/.config/claude/aliases.zsh ] && source ~/.config/claude/aliases.zsh

# ============================================================================
# End of ZSH Configuration
# ============================================================================
