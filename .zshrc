# Add Homebrew's executable directory to the front of the PATH
export PATH=/usr/local/bin:$PATH
export PATH=/opt/homebrew/bin:$PATH
export PATH=/Users/olly/.local/share/bob/nvim-bin:$PATH
export PATH=/Users/olly/go/bin:$PATH
export PATH=/Users/olly/.pub-cache/bin:$PATH
export PATH=/Users/olly/.local/bin:$PATH
export PATH=/opt/homebrew/opt/libpq/bin:$PATH
export PATH="/Users/olly/.cache/.bun/bin:$PATH"
export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH"


# Set config homes
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

alias nvim12="NVIM_APPNAME=nvim/nvim-12 nvim"


# Set nvim theme (this NVIM_THEME is set from my tmux color switch script)
export NVIM_THEME="$(tmux show-environment -g NVIM_THEME | cut -d= -f2)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='ls --color'
alias vim='nvim'
alias c='clear'
alias yal="lazygit -ucd ~/.local/share/yadm/lazygit -w ~ -g ~/.local/share/yadm/repo.git"
alias n="nvim"
alias nx="pnpm nx"
alias l="lazygit"
alias immichsync="ssh root@10.0.0.40 '/mnt/user/backups/backup-scripts/do-immich-lightroom-sync.sh'"

# QMK flash helper (migrated from Fish)
qmk-flash() {
  # Choose build directory based on OS
  case "$(uname)" in
    Darwin)
      build_dir="$HOME/projects/qmk_firmware/.build"
      ;;
    Linux)
      build_dir="/home/olly/projects/qmk_firmware/.build"
      ;;
    *)
      build_dir="$HOME/projects/qmk_firmware/.build"
      ;;
  esac

  # Fetch secret and compile firmware
  export SOFLE_VAR_1="$(op item get "sofle-1" --account "5S2IFKBEWJARZAMDT64SKMOSVA" --fields password --reveal)"
  qmk compile -kb sofle/rev1 -km oliverbutler -e CONVERT_TO=elite_pi -e "SOFLE_VAR_1=$SOFLE_VAR_1"

  # Try to flash UF2 by copying to RPI-RP2 mass-storage device
  for i in {1..20}; do
    case "$(uname)" in
      Darwin)
        if [ -d "/Volumes/RPI-RP2" ]; then
          echo "Found device at: /Volumes/RPI-RP2"
          if cp "$build_dir/sofle_rev1_oliverbutler_elite_pi.uf2" "/Volumes/RPI-RP2/"; then
            echo "Successfully flashed keyboard!"
            return 0
          fi
        fi
        ;;
      Linux)
        mount_point="/tmp/keyboard_mount"
        device_path="$(lsblk -o NAME,LABEL -nr | grep "RPI-RP2" | awk '{print $1}' | head -n1)"
        if [ -n "$device_path" ]; then
          echo "Found device: /dev/$device_path"
          mkdir -p "$mount_point"
          if sudo mount "/dev/$device_path" "$mount_point" \
            && sudo cp "$build_dir/sofle_rev1_oliverbutler_elite_pi.uf2" "$mount_point/" \
            && sudo umount "$mount_point"; then
            echo "Successfully flashed keyboard!"
            return 0
          fi
        fi
        ;;
    esac
    echo "Attempt $i: Device not found, retrying in 1 second..."
    sleep 1
  done

  echo "Error: Failed to find or flash RPI-RP2 device after 20 attempts"
  return 1
}

# Tmux setup
twerk() {
  if tmux ls 2>/dev/null | grep -q work; then
    tmux attach-session -t work
  else
    tmux new-session -s work \; send-keys "zn col" C-m
  fi
}

tome() {
  if tmux ls 2>/dev/null | grep -q home; then
    tmux attach-session -t home
  else
    tmux new-session -s home
  fi
}

nvim() {
  ~/.config/fish/nvim.sh "$@"
}

zn() {
  z "$1"
  nvim
}

src() {
  source ~/.zshrc
}


## [Completion]
## Completion scripts setup. Remove the following line to uninstall
[[ -f /Users/olly/.config/.dart-cli-completion/zsh-config.zsh ]] && . /Users/olly/.config/.dart-cli-completion/zsh-config.zsh || true
## [/Completion]


# pnpm
export PNPM_HOME="/Users/olly/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/postgresql@14/bin:$PATH"


# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env --use-on-cd --shell zsh --log-level=quiet)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/olly/.lmstudio/bin"
# End of LM Studio CLI section

