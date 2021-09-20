require "json"
require "rsub"
require "./arguments"

# Builds a command string from command constructor.
# Each set of arguments can include {} placeholders.
#
# Example:
#
# CommandBuilder.build do |builder|
#   builder.add("evaluate-commands", ["-draft", "{}"])
#   builder.add("execute-keys", ["<a-i>b", "i<backspace><esc>", "a<del><esc>"])
# end
#
# ⇒ 'evaluate-commands' '-draft' '''execute-keys'' ''<a-i>b'' ''i<backspace><esc>'' ''a<del><esc>'''

class Kakoune::CommandBuilder
  include Arguments

  # Aliases
  alias Command = Array(String)

  # Properties
  property input = [] of Command

  # Creates a new builder.
  def initialize
  end

  # Creates a new builder, with its configuration specified in the block.
  def self.new(&block)
    new.tap do |builder|
      yield builder
    end
  end

  # Builds command from block.
  def self.build(&block : self ->)
    new(&block).build
  end

  # Adds a single command.
  def add(command : String, arguments : Array(String))
    command = [command] + arguments
    add(command)
  end

  def add(command : Command)
    input.push(command)
  end

  # Adds multiple commands.
  def add(commands : Array(Command))
    input.concat(commands)
  end

  # Adds commands from a JSON stream.
  #
  # Input example:
  #
  # [["echo", "kanto"]]
  def add(io : IO)
    add(Array(Command).from_json(io))
  end

  # Support for JSON Lines
  # https://jsonlines.org
  def add(io : IO, lines : Bool)
    if lines
      add(from_lines(io))
    else
      add(io)
    end
  end

  # JSON Lines
  # https://jsonlines.org
  #
  # Reads the entire input stream into a large array.
  #
  # Input example:
  #
  # ["echo", "kanto"]
  # ["echo", "johto"]
  private def from_lines(io : IO)
    io.each_line.map do |line|
      Command.from_json(line)
    end.to_a
  end

  # Builds command.
  def build
    Log.debug &.emit("Building command", input: input)

    # Initialize the stack with the last set of arguments.
    stack = [
      quote(input.pop)
    ]

    input.reverse_each do |arguments|
      arguments = arguments.reverse_each.map do |argument|
        RSub.new(argument).gsub("{}") do
          stack.pop
        end
      end.to_a.reverse

      stack << quote(arguments)
    end

    command = stack.reverse.join('\n')

    Log.debug &.emit("Building command", output: command)

    command
  end
end
