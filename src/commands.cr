require "fifo"
require "json"
require "./arguments"
require "./position"

module Kakoune::Commands
  def get(expansion)
    get([expansion])
  end

  def get(*expansions)
    get(expansions)
  end

  def get(expansions : Iterable)
    get(expansions.to_a)
  end

  def get(expansions : Array)
    quoted_string = FIFO.consume do |fifo|
      send("evaluate-commands", ["--", "echo", "-to-file", fifo.path.to_s, "-quoting", "kakoune", "--"] + expansions)
      fifo.reader.gets_to_end
    end

    Arguments.parse(quoted_string)
  end

  def fifo(io)
    FIFO.consume do |fifo|
      send("edit!", ["-fifo", fifo.path.to_s, "*fifo*"])
      Process.run("tee", { fifo.path.to_s }, input: io)
    end
  end

  def pipe(command, arguments)
    selections = get("%val{selections}")
    input = IO::Memory.new(selections.to_json)
    process = Process.new(command, arguments, input: input, output: :pipe)
    selections = Array(String).from_json(process.output)
    set_selections_content(selections)
  end

  def set_selections_content(selections)
    pipe_selections = <<-EOF
      set-register dquote #{Arguments.quote selections}
      execute-keys R
    EOF
    send("evaluate-commands", ["-save-regs", %("), pipe_selections])
  end
end
