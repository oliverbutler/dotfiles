LUA = lua
BUSTED = busted
TEST_DIR = .

all: test

test:
	@echo "Running all tests..."
	@find $(TEST_DIR) -name "*_spec.lua" | xargs $(BUSTED)

watch:
	@echo "Running tests in watch mode..."
	@if command -v inotifywait >/dev/null 2>&1; then \
		while true; do \
			find $(TEST_DIR) -name "*_spec.lua" | xargs $(BUSTED); \
			inotifywait -qre close_write $(TEST_DIR); \
		done; \
	elif command -v fswatch >/dev/null 2>&1; then \
		fswatch -o $(TEST_DIR) | xargs -n1 -I{} make test; \
	else \
		echo "Error: Neither inotifywait nor fswatch found. Please install one of them."; \
		exit 1; \
	fi

help:
	@echo "Available targets:"
	@echo "  test       - Run all test files (*_spec.lua)"
	@echo "  watch      - Run tests in watch mode, re-running on file changes"
