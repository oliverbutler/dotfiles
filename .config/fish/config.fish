# ~/.config/fish/config.fish
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx LG_CONFIG_FILE $XDG_CONFIG_HOME/lazygit/config.yml
set -gx KUBECONFIG $HOME/.kube/config

set -gx EDITOR nvim

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

alias git-ai="bun ~/.config/git-ai/index.ts"

function nvim
    if test (count $argv) -eq 0
        # No arguments provided, open current directory
        if string match -q "$HOME/.config*" (pwd)
            GIT_DIR=$HOME/.local/share/yadm/repo.git command nvim
        else
            command nvim
        end
    else
        # Arguments provided, behave as before
        if string match -q "$HOME/.config*" (pwd)
            GIT_DIR=$HOME/.local/share/yadm/repo.git command nvim $argv
        else
            command nvim $argv
        end
    end
end

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

# nix
alias rebuildfw="sudo nixos-rebuild switch -I nixos-config=/home/olly/.config/nixos/olly-fw.nix"
alias rebuilddesktop="sudo nixos-rebuild switch -I nixos-config=/home/olly/.config/nixos/olly-desktop.nix"

alias parsec="wakeonlan d8:bb:c1:9a:de:d1 && flatpak run com.parsecgaming.parsec"

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

    z $argv[1]
    nvim

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

alias lightroomsync="ssh root@10.0.0.40 '/mnt/user/backups/backup-scripts/do-immich-lightroom-sync.sh'"

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

function qmk-flash
    # Set build directory based on OS
    switch (uname)
        case Darwin
            set build_dir "$HOME/projects/qmk_firmware/.build"
        case Linux
            set build_dir "/home/olly/projects/qmk_firmware/.build"
    end

    set -x SOFLE_VAR_1 (op item get "sofle-1" --account "5S2IFKBEWJARZAMDT64SKMOSVA" --fields password --reveal)
    qmk compile -kb sofle/rev1 -km oliverbutler -e CONVERT_TO=elite_pi -e "SOFLE_VAR_1=$SOFLE_VAR_1"
    
    for i in (seq 20)
        switch (uname)
            case Darwin
                # macOS: Find the mounted RPI-RP2 volume
                # Check if RPI-RP2 volume is mounted
                if test -d "/Volumes/RPI-RP2"
                    echo "Found device at: /Volumes/RPI-RP2"
                    if cp $build_dir/sofle_rev1_oliverbutler_elite_pi.uf2 "/Volumes/RPI-RP2/"
                        echo "Successfully flashed keyboard!"
                        return 0
                    end
                end

            case Linux
                # Linux: Use lsblk to find and mount the device
                set mount_point "/tmp/keyboard_mount"
                set device_path (lsblk -o NAME,LABEL -nr | grep "RPI-RP2" | cut -d' ' -f1)
                
                if test -n "$device_path"
                    echo "Found device: /dev/$device_path"
                    
                    # Create mount point if it doesn't exist
                    mkdir -p $mount_point
                    
                    # Mount, copy, unmount in one go
                    if sudo mount /dev/$device_path $mount_point && \
                       sudo cp $build_dir/sofle_rev1_oliverbutler_elite_pi.uf2 $mount_point/ && \
                       sudo umount $mount_point
                        echo "Successfully flashed keyboard!"
                        return 0
                    end
                end
        end
        
        echo "Attempt $i: Device not found, retrying in 1 second..."
        sleep 1
    end
    
    echo "Error: Failed to find or flash RPI-RP2 device after 10 attempts"
    return 1
end
zoxide init fish | source
