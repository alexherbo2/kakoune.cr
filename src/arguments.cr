require "string_scanner"

module Kakoune::Arguments
  extend self

  # Returns a string.
  # Escapes Kakoune string wrapped into single quote.
  def escape(string : String)
    string.gsub("'", "''")
  end

  # Returns a string.
  # Converts to Kakoune string by wrapping into quotes and escaping.
  def quote(string : String)
    "'%s'" % escape(string)
  end

  def quote(*strings)
    quote(strings)
  end

  # Returns a string.
  # Wraps each argument in single quotes, doubling-up embedded quotes.
  def quote(strings : Iterable)
    strings.join(' ') do |string|
      quote(string)
    end
  end

  # Returns a string.
  # Removes doubling-up embedded quotes.
  def unescape(string : String)
    string.gsub("''", "'")
  end

  # Returns an array of strings.
  # Parses the output of `echo -quoting kakoune`.
  def parse(string : String)
    tokens = [] of String

    string_scanner = StringScanner.new(string.chomp)

    until string_scanner.eos?
      # Search for opening single quote.
      string_scanner.skip_until(/'/)
      opening_position = string_scanner.offset

      # Search for closing single quote.
      loop do
        # Scans the string until the closing quote,
        string_scanner.skip_until(/'/)
        # and skips doubling-up embedded quotes.
        next if string_scanner.skip(/'/)

        break
      end
      closing_position = string_scanner.offset - 2

      # Select the resulting quoted string.
      quoted_string = string[opening_position..closing_position]

      token = unescape(quoted_string)
      tokens << token
    end

    tokens
  end

  # Returns a string.
  # Escapes Kakoune completion field.
  def escape_completion_field(string : String)
    string.gsub({ '|' => "\\|", '\\' => "\\\\" })
  end
end
