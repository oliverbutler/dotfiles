#!/opt/homebrew/bin/fish

# Focus wezterm
open -a WezTerm

# Ensure the tmux session exists
tmux has-session -t work
if test $status -ne 0
    echo "Session 'twerk' does not exist."
    exit 1
end

for f in $argv
    if test -f "$f"
        # Open a new window in the tmux session "twerk" and run `nvim` with the CSV file
        tmux new-window -t work "nvim '$f'; exec $SHELL"
    else
        echo "The file '$f' does not exist."
    end
end
