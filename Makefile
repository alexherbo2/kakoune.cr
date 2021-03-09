static ?= no

ifeq ($(static),yes)
  build = build-static
else
  build = build
endif

build:
	shards build --release

build-static:
	./scripts/build-static

install: $(build)
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/kcr" ~/.local/bin
	bin/kcr install commands
	bin/kcr install desktop

uninstall:
	rm -f ~/.local/bin/kcr

clean:
	rm -Rf bin lib shard.lock
