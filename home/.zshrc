# Minimal zsh — history, completion, plugins, starship. No oh-my-zsh needed.

# PATH
export PATH="$HOME/.local/bin:$PATH"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt inc_append_history share_history hist_ignore_all_dups hist_reduce_blanks

# Shell behavior
setopt autocd          # type a dir name to cd into it, no `cd` needed
setopt correct          # suggest fixes for typo'd commands
setopt extendedglob     # richer globbing (e.g. ^exclude, ~alt patterns)

# Completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Plugins (installed via pacman)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Aliases
alias ls='eza --color=auto --icons --group-directories-first'
alias ll='eza -alh --icons --group-directories-first'
alias lt='eza --tree --icons --group-directories-first'
alias grep='grep --color=auto'
alias vim='nvim'
alias update='~/dotfiles/scripts/sysmaintenance.sh'
alias lg='lazygit'

# fzf (Ctrl+R history, Ctrl+T files, Alt+C cd — fzf 0.48+)
eval "$(fzf --zsh)"

# zoxide — z to jump, zi to fuzzy-pick from recent dirs via fzf
eval "$(zoxide init zsh)"

# Prompt
eval "$(starship init zsh)"

# Greeting
fastfetch
