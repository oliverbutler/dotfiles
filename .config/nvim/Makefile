LUA = lua
BUSTED = busted
TEST_DIR = .

all: test

test:
	@echo "Running all tests..."
	@find $(TEST_DIR) -name "*_spec.lua" | xargs $(BUSTED)

help:
	@echo "Available targets:"
	@echo "  test       - Run all test files (*_spec.lua)"
