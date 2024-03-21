# Dot files

## Lazygit

```yml
paging:
  colorArg: always
  pager: delta --show-syntax-themes --dark --line-numbers
```

## Precommit for NX

```bash
#!/bin/sh

# Save the current state of the index (staged changes)
STASH_NAME=$(git stash create "pre-commit-$(date +%Y%m%d%H%M%S)")

# Stash any changes not yet staged so the format command won't pick them up
git stash push -q --keep-index

# Run the formatter and capture its output
FORMAT_OUTPUT=$(pnpm nx format:write)

# Re-apply unstaged changes to the working directory
git stash pop -q

# If the stash command above created a stash, apply it to revert the index to original pre-hook state
if [ -n "$STASH_NAME" ]; then
  git stash apply --index "$STASH_NAME"
  git stash drop "$STASH_NAME"
fi

# Check if the format command output indicates any files were changed
if [ -n "$FORMAT_OUTPUT" ]; then
  echo "Files were formatted. Please review the changes, stage them, and commit again."
  echo "$FORMAT_OUTPUT"
  exit 1
fi
```
