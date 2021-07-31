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
      evaluate-commands -try-client #{Arguments.escape name} -- #{Arguments.escape command}
    EOF
  end

  # Add a few switches to evaluate-commands for perfect command forwarding to another context.
  def send(command, arguments)
    session.send("evaluate-commands", ["-try-client", name, "-verbatim", "--", command] + arguments)
    send("try focus")
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
