require "./session"
require "./commands"
require "./arguments"
require "./buffer"

class Kakoune::Client
  include Commands

  property session : Session
  property name : String

  def initialize(@session, @name)
  end

  def send(command)
    session.send <<-EOF
      evaluate-commands -try-client #{Arguments.quote name} -- #{Arguments.quote command}
    EOF
  end

  # Add a few switches to evaluate-commands for perfect command forwarding to another context.
  def send(command, arguments)
    session.send("evaluate-commands", ["-try-client", name, "-verbatim", "--", command] + arguments)
  end

  def edit(files : Array(Path | String), position : Position?)
    return if files.empty?

    command = String.build do |string|
      files.each do |file|
        string.puts(Arguments.quote("edit", file.to_s))
      end

      if position
        string.puts(Arguments.quote("edit", files.first.to_s, position.line.to_s, position.column.to_s))
      end

      string.puts("try focus")
    end

    send(command)
  end

  def exists?
    session.clients.any? do |client|
      client.name == name
    end
  end

  def current_buffer
    buffer_name = get("%val{bufname}")[0]
    session.buffer(buffer_name)
  end
end
