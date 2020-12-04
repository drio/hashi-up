SHELL := bash
Version := $(shell git describe --tags --dirty)
# Version := "dev"
GitCommit := $(shell git rev-parse HEAD)
LDFLAGS := "-s -w -X github.com/jsiebens/hashi-up/cmd.Version=$(Version) -X github.com/jsiebens/hashi-up/cmd.GitCommit=$(GitCommit)"
.PHONY: all

.PHONY: build
build: generate
	go build -ldflags $(LDFLAGS)

.PHONY: dist
dist: generate
	mkdir -p dist
	GOOS=linux go build -ldflags $(LDFLAGS) -o dist/hashi-up
	GOOS=darwin go build -ldflags $(LDFLAGS) -o dist/hashi-up-darwin
	GOOS=linux GOARCH=arm GOARM=6 go build -ldflags $(LDFLAGS) -o dist/hashi-up-arm
	GOOS=linux GOARCH=arm64 go build -ldflags $(LDFLAGS) -o dist/hashi-up-arm64
	GOOS=windows go build -ldflags $(LDFLAGS) -o dist/hashi-up.exe

generate:
	go get github.com/markbates/pkger/cmd/pkger
	pkger -include /scripts

.PHONY: compress
compress:
	for f in dist/hashi-up*; do upx $$f; done

.PHONY: hash
hash:
	for f in dist/hashi-up*; do shasum -a 256 $$f > $$f.sha256; done