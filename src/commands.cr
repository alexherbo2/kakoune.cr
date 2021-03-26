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

  def edit(file, position : Position)
    send("edit", [file.to_s, position.line.to_s, position.column.to_s])
  end

  def edit(file)
    send("edit", [file.to_s])
  end

  def edit(*files)
    edit(files)
  end

  def edit(files : Iterable)
    files.each do |file|
      edit(file)
    end
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
    pipe_selections = <<-EOF
      set-register dquote #{Arguments.escape selections}
      execute-keys R
    EOF
    send("evaluate-commands", ["-save-regs", %("), pipe_selections])
  end
end
