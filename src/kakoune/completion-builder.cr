require "json"
require "./arguments"
require "./command-builder"

class Kakoune::CompletionBuilder
  include Arguments

  # Aliases
  alias Command = Array(String)
  alias Candidate = { String, Array(Command), String }

  # Properties
  property name : String
  property line : Int32
  property column : Int32
  property length : Int32
  property timestamp : Int32

  # Constructor
  property constructor = [] of Candidate

  # Creates a new builder.
  def initialize(@name, @line, @column, @length, @timestamp)
  end

  # Creates a new builder, with its configuration specified in the block.
  def self.new(name, line, column, length, timestamp, &block)
    new(name, line, column, length, timestamp).tap do |builder|
      yield builder
    end
  end

  # Builds command from block.
  def self.build(name, line, column, length, timestamp, &block : self ->)
    new(name, line, column, length, timestamp, &block).build
  end

  # Adds a single candidate.
  def add(text : String, command : Array(Command), menu : String)
    constructor.push({ text, command, menu })
  end

  # Adds multiple candidates.
  def add(candidates : Array(Candidate))
    constructor.concat(candidates)
  end

  # Adds candidates from a JSON stream.
  def add(io : IO)
    add(Array(Candidate).from_json(io))
  end

  # Builds the completion command.
  def build
    Log.debug { constructor.to_json }

    command = String.build do |string|
      string << quote("set-option", "window", name, build_header(line, column, length, timestamp)) << " "

      constructor.each do |text, select_command, menu_text|
        string << quote(build_candidate(text, select_command, menu_text)) << " "
      end
    end

    Log.debug { command }

    command
  end

  private def build_header(line, column, length, timestamp)
    "#{line}.#{column}+#{length}@#{timestamp}"
  end

  private def escape_field(field)
    field.gsub({ '|' => "\\|", '\\' => "\\\\" })
  end

  private def build_candidate(text, command, menu)
    select_command = CommandBuilder.build do |builder|
      builder.add(command)
    end

    # Escape fields
    text = escape_field(text)
    select_command = escape_field(select_command)
    menu_text = escape_field(menu)

    # Build candidate
    candidate = "#{text}|#{select_command}|#{menu_text}"
  end
end
