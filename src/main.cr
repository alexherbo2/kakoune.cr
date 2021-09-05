require "./env"
require "./kakoune"
require "./kakoune/cli"

Kakoune::CLI.start(ARGV)
