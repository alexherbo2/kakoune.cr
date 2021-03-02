require "fifo"
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

  def cat
    FIFO.consume do |fifo|
      send("write", ["-method", "overwrite", fifo.path.to_s])

      content = fifo.reader.gets_to_end
      [{ name: name, content: content }]
    end
  end

  def cat(buffer_names)
    FIFO.consume do |fifo|
      send("evaluate-commands", ["-buffer", buffer_names.join(','), "write", "-method", "overwrite", fifo.path.to_s])

      buffer_names.map do |name|
        content = fifo.reader.gets_to_end
        { name: name, content: content }
      end
    end
  end
end
