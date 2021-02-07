build:
	shards build --release

install: build
	mkdir -p ~/.local/bin
	ln -sf "${PWD}/bin/kcr" ~/.local/bin
	bin/kcr install commands
	bin/kcr install desktop

uninstall:
	rm -f ~/.local/bin/kcr

clean:
	rm -Rf bin lib shard.lock
