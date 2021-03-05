require "./session"
require "./commands"
require "./arguments"

class Kakoune::Buffer
  include Commands

  property session : Session
  property name : String

  def initialize(@session, @name)
  end

  def content
    FIFO.consume do |fifo|
      send("write", ["-method", "overwrite", fifo.path.to_s])
      fifo.reader.gets_to_end
    end
  end

  def send(command)
    session.send <<-EOF
      evaluate-commands -buffer #{Arguments.escape name} -- #{Arguments.escape command}
    EOF
  end

  # Add a few switches to evaluate-commands for perfect command forwarding to another context.
  def send(command, arguments)
    session.send("evaluate-commands", ["-buffer", name, "-verbatim", "--", command] + arguments)
  end

  def exists?
    session.buffers.any? do |buffer|
      buffer.name == name
    end
  end
end
