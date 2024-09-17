# ~/.config/fish/config.fish
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx LG_CONFIG_FILE $XDG_CONFIG_HOME/lazygit/config.yml
set -gx KUBECONFIG $HOME/projects/homelab/kubeconfig

set PATH /Users/olly/bin $PATH
set PATH /opt/homebrew/bin $PATH
set PATH ~/go/bin $PATH
set PATH /opt/homebrew/opt/openvpn/sbin $PATH
set PATH /Users/olly/.cargo/bin $PATH
set PATH /Users/olly/flutter/bin $PATH
set PATH /Users/olly/Library/Application\ Support/JetBrains/Toolbox/scripts $PATH
set PATH /usr/local/bin $PATH
set PATH /Users/olly/projects/oimage $PATH
set PATH ~/.pub-cache/bin $PATH
set PATH ~/.local/share/bob/nvim-bin $PATH
set PATH ~/development/flutter/bin $PATH


set -x nvm_default_version 18

alias fishr="source ~/.config/fish/config.fish"

# enable vim mode
fish_vi_key_bindings

function nvim
    if string match -q "$HOME/.config*" (pwd)
        GIT_DIR=$HOME/.local/share/yadm/repo.git command nvim $argv
    else
        command nvim $argv
    end
end

# function lazygit
# 	command lazygit --use-config-file="$HOME/.config/lazygit/config.yml" $argv
# end

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


# Kubes
alias k="kubectl"

# Tmux Helpers
# twerk will open tmux for work, "work" OR create session if missing
# tome will open tmux for home, OR create session if missing

function twerk
	if test (tmux ls | grep work)
		tmux a -t work
	else
		tmux new-session -s work
		tmux send-keys -t work "zn col" C-m
	end
end

function tome
	if test (tmux ls | grep home)
		tmux a -t home
	else
		tmux new-session -s home
	end
end

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
# Set Delta as the default pager for Git
git config --global core.pager 'delta'
# Set Delta as the diff filter for interactive usage
git config --global interactive.diffFilter 'delta --color-only'
# Delta specific settings
git config --global delta.navigate 'true'  # Allows navigation between diff sections
# Uncomment one of the following if you need to fix the color mode
#git config --global delta.dark 'true'    # For dark terminal backgrounds
#git config --global delta.light 'true'   # For light terminal backgrounds
# Set merge configuration
git config --global merge.conflictstyle 'diff3'
# Set diff configuration
git config --global diff.colorMoved 'default'

git config --global alias.yolo '!git commit -am "$(curl -sL http://whatthecommit.com/index.txt)"' 

alias gpnv="git push --no-verify"
alias gpsu="git push --set-upstream origin HEAD"
alias gpsunv="git push --set-upstream origin HEAD --no-verify"
alias gpr="git pull --rebase origin master"
alias gprm="git pull --rebase origin main"

# gpm regardless of branch we're on, pulls master from prod
alias gpm="git pull origin master"

alias dp1="~/projects/m1ddc/m1ddc display 1 set input 15"
alias dp2="~/projects/m1ddc/m1ddc display 1 set input 16"


alias smac="dp2"
alias swin="dp1"

# Reccomended for NX
alias nx="pnpm nx"

# LazyGit/Git
alias yal="lazygit -ucd ~/.local/share/yadm/lazygit -w ~ -g ~/.local/share/yadm/repo.git"

starship init fish | source

# If .nvmrc exists, use it
if test -e .nvmrc	
    nvm use
end


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
