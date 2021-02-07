require "./session"
require "./commands"

class Kakoune::Client
  include Commands

  property session : Session
  property name : String

  def initialize(@session, @name)
  end

  # Add a few switches to evaluate-commands for perfect command forwarding to another context.
  def send(command, arguments)
    session.send("evaluate-commands", ["-try-client", name, "-verbatim", "--", command] + arguments)
  end

  def exists?
    session.clients.any? do |client|
      client.name == name
    end
  end
end
