require "string_scanner"
require "./argument"

module Kakoune::Arguments
  extend self

  # Returns a string.
  # Wraps each argument in single quotes, doubling-up embedded quotes.
  def escape(argument : Argument)
    escape(argument.to_s)
  end

  def escape(string : String)
    "'" + string.gsub("'", "''") + "'"
  end

  def escape(*strings)
    escape(strings)
  end

  def escape(strings : Iterable)
    strings.map do |string|
      escape(string)
    end.join(" ")
  end

  # Returns a string.
  # Removes doubling-up embedded quotes.
  def unescape(string)
    string.gsub("''", "'")
  end

  # Returns an array of strings.
  # Parses the output of `echo -quoting kakoune`.
  def parse(string)
    tokens = [] of String

    string_scanner = StringScanner.new(string.chomp)

    until string_scanner.eos?
      # Opening quote
      string_scanner.skip_until(/'/)
      opening_position = string_scanner.offset

      # Closing quote
      loop do
        # Scans the string until the closing quote,
        string_scanner.skip_until(/'/)
        # and skips doubling-up embedded quotes.
        next if string_scanner.skip(/'/)

        break
      end
      closing_position = string_scanner.offset - 2

      # Quoted string
      quoted_string = string[opening_position..closing_position]

      token = unescape(quoted_string)
      tokens << token
    end

    tokens
  end
end
