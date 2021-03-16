name := kakoune.cr
version := $(shell git describe --tags --always)
target := $(shell llvm-config --host-target)
static ?= no

ifeq ($(static),yes)
  flags += --static
endif

build:
	shards build --release $(flags)

x86_64-unknown-linux-musl:
	scripts/build-linux

x86_64-apple-darwin: build

release: $(target)
	mkdir -p releases
	zip -r releases/$(name)-$(version)-$(target).zip bin share

install: build
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/kcr" ~/.local/bin
	bin/kcr install commands
	bin/kcr install desktop

uninstall:
	rm -f ~/.local/bin/kcr

clean:
	rm -Rf bin lib releases shard.lock
