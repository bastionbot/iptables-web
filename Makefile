BIN_FILE := iptables-server
SRCS := ./main.go

# Git metadata
COMMIT_HASH := $(shell git describe --dirty --always 2>/dev/null || echo "GitNotFound")
BUILD_DATE := $(shell date '+%Y-%m-%d %H:%M:%S')
# VERSION_TAG := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

# Build flags
CFLAGS := -ldflags "-s -w -X 'main.BuildVersion=$(COMMIT_HASH)' -X 'main.BuildDate=$(BUILD_DATE)'"

release:
	go build $(CFLAGS) -o $(BIN_FILE) $(SRCS)

run:
	go run $(SRCS)

clean:
	rm -f $(BIN_FILE)

.PHONY: release run clean
