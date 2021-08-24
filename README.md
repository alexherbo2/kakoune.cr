# kakoune.cr

###### [Installation] | [Guide] | [Manual]

[Installation]: #installation
[Guide]: docs/guide.md
[Manual]: docs/manual.md

kakoune.cr (kcr) is a command-line tool for [Kakoune].

It is a great companion to work with projects, multiple files and headless sessions.

[Kakoune]: https://kakoune.org

[![Thumbnail](https://img.youtube.com/vi_webp/FUndUED1O7Q/maxresdefault.webp)](https://youtube.com/playlist?list=PLdr-HcjEDx_klQYqXIAmBpywj7ggsDPer)
[![Button](https://www.iconfinder.com/icons/317714/download/png/16)](https://youtube.com/playlist?list=PLdr-HcjEDx_klQYqXIAmBpywj7ggsDPer)

###### What can I do?

- Connect applications to Kakoune.
- Control Kakoune from the command-line.
- Manage sessions.
- Write plugins.

Give it a spin: [`kcr tldr`] & [`kcr play`].

[`kcr tldr`]: docs/manual.md#tldr
[`kcr play`]: docs/manual.md#play

See what’s new with [`kcr -V`] | [`kcr --version-notes`] or read the [changelog].

[`kcr -V`]: docs/manual.md#options
[`kcr --version-notes`]: docs/manual.md#options

[Changelog]: CHANGELOG.md

###### How does it work?

kakoune.cr is based around the concept of contexts, which can be set via the [`--session`] and [`--client`] options.

[`--session`]: docs/manual.md#options
[`--client`]: docs/manual.md#options

For example, the following command will open the file in the **main** client of the **kanto** session.

``` sh
kcr edit --session=kanto --client=main pokemon.json
```

Most of the time, you don’t need to specify them.
[`connect`] will forward [`KAKOUNE_SESSION`] and [`KAKOUNE_CLIENT`] environment variables,
which will be used by [`kcr`] to run commands in the specified context.

[`kcr`]: docs/manual.md
[`connect`]: docs/manual.md#connect
[`KAKOUNE_SESSION`]: docs/manual.md#environment-variables
[`KAKOUNE_CLIENT`]: docs/manual.md#environment-variables

**Example** – Connect a terminal:

``` kak
connect terminal
```

**Example** – Connect a program:

``` kak
connect run alacritty
```

## Dependencies

- [Crystal]
- [Shards]
- [jq]

[Crystal]: https://crystal-lang.org
[Shards]: https://github.com/crystal-lang/shards
[jq]: https://stedolan.github.io/jq/

## Installation

### Nightly builds

Download the [Nightly builds].

[Nightly builds]: https://github.com/alexherbo2/kakoune.cr/releases/nightly

### Build from source

Run the following in your terminal:

``` sh
make install
```

### Kakoune definitions

Add the [Kakoune definitions] to your **kakrc**.

``` kak
evaluate-commands %sh{
  kcr init kakoune
}
```

[Kakoune definitions]: docs/manual.md#init-kakoune
