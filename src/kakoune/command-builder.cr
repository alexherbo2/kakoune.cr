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

  property constructor

  # Creates a new builder.
  def initialize
    @constructor = Array(Array(String)).new
  end

  # Creates a new builder, with its configuration specified in the block.
  def self.new(&block)
    new.tap do |builder|
      yield builder
    end
  end

  # Builds command from block.
  def self.build(&block)
    builder = new
    yield builder
    builder.build
  end

  # Adds a single command to the constructor.
  def add(command : String, arguments : Array(String))
    command = [command] + arguments
    add(command)
  end

  def add(command : Array(String))
    constructor.push(command)
  end

  # Adds multiple commands to the constructor.
  def add(commands : Array(Array(String)))
    constructor.concat(commands)
  end

  # Adds commands from a JSON stream to the constructor.
  def add(io : IO)
    add(from_json(io))
  end

  # Builds command.
  def build
    input = constructor.dup

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
  end

  # Parses command constructor from JSON.
  #
  # Example:
  #
  # [
  #   ["echo", "kanto"],
  #   ["echo", "johto"]
  # ]
  #
  # Accepts chunks.
  # Reads the entire input stream into a large array.
  #
  # Example:
  #
  # ["echo", "kanto"]
  # ["echo", "johto"]
  def from_json(json)
    Array(Array(String)).from_json(json)
  rescue
    json.each_line.map do |json|
      Array(String).from_json(json)
    end.to_a
  end
end
