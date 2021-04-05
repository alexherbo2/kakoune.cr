name := kakoune.cr
version := $(shell git describe --tags --always)
target := $(shell llvm-config --host-target)
static ?= no

ifeq ($(static),yes)
  flags += --static
endif

# Ignore Crystal version until `1.0.0` is available
build:
	shards build --release --ignore-crystal-version $(flags)

x86_64-unknown-linux-musl:
	scripts/docker-run make static=yes

x86_64-apple-darwin: build

release: $(target)
	mkdir -p releases
	zip -r releases/$(name)-$(version)-$(target).zip bin share

install: build
	# Install bin/kcr
	install -d ~/.local/bin
	install bin/kcr ~/.local/bin
	# Install share/kcr
	install -d ~/.local/share
	rm -Rf ~/.local/share/kcr
	cp -R share/kcr ~/.local/share
	# Install support
	bin/kcr install commands
	bin/kcr install desktop

uninstall:
	rm -Rf ~/.local/bin/kcr ~/.local/share/kcr

clean:
	rm -Rf bin lib releases shard.lock
