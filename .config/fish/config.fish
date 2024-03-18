# ~/.config/fish/config.fish

set PATH /opt/homebrew/bin $PATH
set PATH /Users/olly/go/bin $PATH
set PATH /opt/homebrew/opt/openvpn/sbin $PATH
set PATH /Users/olly/.cargo/bin $PATH
set PATH /Users/olly/flutter/bin $PATH
set PATH /Users/olly/Library/Application\ Support/JetBrains/Toolbox/scripts $PATH
set PATH /usr/local/bin $PATH
set PATH /Users/olly/projects/oimage $PATH

set -x nvm_default_version 14


#if status is-interactive
#and not set -q TMUX
#    exec tmux
#end

alias fishr="source ~/.config/fish/config.fish"

alias wakeomega="wakeonlan -i 255.255.255.255 -p 7 d8:bb:c1:9a:de:d1"
alias sleepomega="ssh omega 'date && winsleep'"
alias ll="exa -l --icons"
alias llo="ll --octal-permissions"
alias ls="exa --icons"
alias tree="exa --tree --level=2 -a"
alias n="nnn"
alias nf="neofetch"
alias nano="nvim"
alias vim="nvim"
alias bim="say bim"
alias vom="say vom"
alias c="clear"

alias confish="vim ~/.config/fish/config.fish"
alias sourcefish="source ~/.config/fish/config.fish"

alias gpnv="git push --no-verify"
alias gpsu="git push --set-upstream origin HEAD"
alias gpsunv="git push --set-upstream origin HEAD --no-verify"
alias gpr="git pull --rebase origin master"
alias gprm="git pull --rebase origin main"

alias dp1="~/projects/m1ddc/m1ddc display 1 set input 15"
alias dp2="~/projects/m1ddc/m1ddc display 1 set input 16"


alias smac="dp2"
alias swin="dp1"

# Reccomended for NX
alias pnx="pnpm nx"

# LazyGit/Git
alias yal="lazygit -ucd ~/.local/share/yadm/lazygit -w ~ -g ~/.local/share/yadm/repo.git"

starship init fish | source

nvm use 20

# pnpm
set -gx PNPM_HOME "/Users/olly/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
