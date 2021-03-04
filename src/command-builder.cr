require "rsub"
require "./command-constructor"
require "./arguments"

class Kakoune::CommandBuilder
  include Arguments

  property arguments : CommandConstructor

  def initialize(@arguments)
  end

  def self.build(arguments)
    new(arguments).build
  end

  # Builds a command string from arguments.
  # Each set can include {} placeholders.
  #
  # Example:
  #
  # build [
  #   ["evaluate-commands", "-draft", "{}"],
  #   ["execute-keys", "<a-i>b", "i<backspace><esc>", "a<del><esc>"]
  # ]
  #
  # ⇒ 'evaluate-commands' '-draft' '''execute-keys'' ''<a-i>b'' ''i<backspace><esc>'' ''a<del><esc>'''
  def build
    # Initialize the stack with the last set of arguments.
    stack = [
      escape(arguments.pop)
    ]

    arguments.reverse_each do |arguments|
      arguments = arguments.reverse_each.map do |argument|
        RSub.new(argument).gsub("{}") do
          stack.pop
        end
      end.to_a.reverse

      stack.unshift escape(arguments)
    end

    command = stack.pop
  end
end
