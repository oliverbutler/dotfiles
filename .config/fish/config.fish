# ~/.config/fish/config.fish
set XDG_CONFIG_HOME $HOME/.config

set PATH /opt/homebrew/bin $PATH
set PATH /Users/olly/go/bin $PATH
set PATH /opt/homebrew/opt/openvpn/sbin $PATH
set PATH /Users/olly/.cargo/bin $PATH
set PATH /Users/olly/flutter/bin $PATH
set PATH /Users/olly/Library/Application\ Support/JetBrains/Toolbox/scripts $PATH
set PATH /usr/local/bin $PATH
set PATH /Users/olly/projects/oimage $PATH
set PATH ~/.pub-cache/bin $PATH
set PATH ~/.local/share/bob/nvim-bin $PATH

set -x nvm_default_version 14


#if status is-interactive
#and not set -q TMUX
#    exec tmux
#end

alias fishr="source ~/.config/fish/config.fish"

alias wakeomega="wakeonlan -i 255.255.255.255 -p 7 d8:bb:c1:9a:de:d1"
alias sleepomega="ssh omega 'date && winsleep'"
# alias ll="exa -l --icons"
# alias llo="ll --octal-permissions"
# alias ls="exa --icons"
# alias tree="exa --tree --level=2 -a"
alias nf="neofetch"
alias nano="nvim"
alias vim="nvim"
alias bim="say bim"
alias vom="say vom"
alias c="clear"
alias n="nvim"

alias pair="upterm host --force-command 'tmux a' -- tmux a"
alias paircopy="upterm session current | grep '^SSH' | sed 's/^SSH Session: *//' | tr -d '\n' | pbcopy"

function zn
    if test (count $argv) -eq 0
        echo "Usage: zn <directory>"
        return 1
    end

    set dir (z -e $argv[1])

    if test -n "$dir"
        cd "$dir"
        nvim
    else
        echo "Directory not found in z database"
        return 1
    end
end

alias confish="vim ~/.config/fish/config.fish"
alias sourcefish="source ~/.config/fish/config.fish"

# Git
git config --global pull.rebase true
git config --global rebase.autoStash true
git config --global push.autoSetupRemote true
git config --global user.name "Oliver Butler"
git config --global user.email dev@oliverbutler.uk
git config --global --type=bool rebase.updateRefs true

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
alias nx="pnpm nx"

# LazyGit/Git
alias yal="lazygit -ucd ~/.local/share/yadm/lazygit -w ~ -g ~/.local/share/yadm/repo.git"

starship init fish | source

nvm use 18.17
nvm use

# pnpm
set -gx PNPM_HOME "/Users/olly/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

function prmake
	# Get the current branch name as the default PR title
	set branch_name (git symbolic-ref --short HEAD)

	# If an argument is provided, it's used as the PR title, not the branch name
	if set -q argv[1]
		set pr_title $argv[1]
	else
		# If no PR title is provided, use the current branch name with modifications as the title
		set pr_title $branch_name
	end

	# Apply transformations to the branch name for the PR title
	set pr_title (string replace -r '^feature\/' 'feat: ' $pr_title)
	set pr_title (string replace -r '^bugfix\/' 'fix: ' $pr_title)
	set pr_title (string replace -r '^documentation\/' 'docs: ' $pr_title)
	set pr_title (string replace -r '^style\/' 'style: ' $pr_title)
	set pr_title (string replace -r '^refactoring\/' 'refactor: ' $pr_title)
	set pr_title (string replace -r '^testing\/' 'test: ' $pr_title)
	set pr_title (string replace -r '^chore\/' 'chore: ' $pr_title)

	# Global replacement of hyphens with spaces in the title
	set pr_title (string replace -a '-' ' ' $pr_title)

	# Push the current branch; no branch creation or checkout is performed
	git push --set-upstream origin $branch_name

	# Create a PR with the specified or modified title
	gh pr create --title "$pr_title" --fill

	# Open the newly created PR in the web browser
	gh pr view --web
end
