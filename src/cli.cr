require "option_parser"
require "json"
require "file_utils"
require "./kakoune"
require "./env"

PROGRAM_PATH = Path[Process.executable_path || PROGRAM_NAME]
RUNTIME_PATH = PROGRAM_PATH.join("../../share/kcr").expand

module Kakoune::CLI
  extend self

  KAKOUNE_LOGO_URL = "https://github.com/mawww/kakoune/raw/master/doc/kakoune_logo.svg"

  struct Options
    property command = :command
    property context = Context.new(session: ENV["KAKOUNE_SESSION"]?, client: ENV["KAKOUNE_CLIENT"]?)
    property position = Position.new
    property raw = false
    property debug = false
  end

  def debug(context, arguments)
    message = {
      session: context.session_name,
      client: context.client_name,
      arguments: arguments
    }
    print_json(message)
    context.session.send("echo", ["-debug", "kcr", message.to_json])
  end

  def start(argv)
    # Options
    options = Options.new

    # Option parser
    option_parser = OptionParser.new do |parser|
      parser.banner = "Usage: kcr <command> [arguments]"

      parser.on("-s NAME", "--session=NAME", "Session name") do |name|
        options.context.session_name = name
      end

      parser.on("-c NAME", "--client=NAME", "Client name") do |name|
        options.context.client_name = name
      end

      parser.on("-r", "--raw", "Use raw output") do
        options.raw = true
      end

      parser.on("-R", "--no-raw", "Do not use raw output") do
        options.raw = false
      end

      parser.on("-d", "--debug", "Debug mode") do
        options.debug = true
      end

      parser.on("-h", "--help", "Show help") do
        puts parser
        exit
      end

      parser.on("init", "Print functions") do
        options.command = :init

        parser.banner = "Usage: kcr init <name>"

        parser.on("kakoune", "Print Kakoune definitions") do
          options.command = :init_kakoune
        end

        parser.on("starship", "Print Starship configuration") do
          options.command = :init_starship
        end
      end

      parser.on("install", "Install files") do
        options.command = :install

        parser.banner = "Usage: kcr install <name>"

        parser.on("commands", "Install commands") do
          options.command = :install_commands
        end

        parser.on("desktop", "Install desktop application") do
          options.command = :install_desktop_application
        end
      end

      parser.on("play", "Start playground") do
        options.command = :play
      end

      parser.on("create", "Create a new session") do
        options.command = :create
      end

      parser.on("attach", "Connect to session") do
        options.command = :attach
      end

      parser.on("list", "List sessions") do
        options.command = :list
      end

      parser.on("shell", "Start an interactive shell") do
        options.command = :shell
      end

      parser.on("edit", "Edit files") do
        options.command = :edit
      end

      parser.on("open", "Open files") do
        options.command = :open
      end

      parser.on("send", "Send commands to client at session") do
        options.command = :send
      end

      parser.on("echo", "Print arguments") do
        options.command = :echo
      end

      parser.on("get", "Get states from a client in session") do
        options.command = :get
      end

      parser.on("cat", "Print buffer content") do
        options.command = :cat
      end

      parser.on("escape", "Escape arguments") do
        options.command = :escape
      end

      parser.on("help", "Show help") do
        options.command = :help
      end

      parser.invalid_option do |flag|
        STDERR.puts "Error: Unknown option: #{flag}"
        STDERR.puts parser
        exit(1)
      end
    end

    # Parse options
    option_parser.parse(argv)

    parse_position(argv) do |line, column|
      options.position.line = line
      options.position.column = column
    end

    position_option = "+#{options.position.line}:#{options.position.column}"

    # Current context
    context = options.context.scope

    # Run command
    case options.command
    when :init
      option_parser.parse(["init", "--help"])

    when :init_kakoune
      puts read("init/kakoune.kak")

    when :init_starship
      puts read("init/starship.toml")

    when :install
      option_parser.parse(["install", "--help"])

    when :install_commands
      install_commands

    when :install_desktop_application
      install_desktop_application

    when :play
      file = if argv.first?
        argv.first
      else
        RUNTIME_PATH / "init/example.kak"
      end

      config = <<-EOF
        source #{RUNTIME_PATH / "init/kakoune.kak"}
        source #{RUNTIME_PATH / "init/playground.kak"}
        initialize #{file}
      EOF

      Process.run("kak", ["-e", config], input: :inherit, output: :inherit, error: :inherit)

    when :create
      session_name = argv.fetch(0, options.context.session_name)

      if session_name
        Session.create(session_name)
      end

    when :attach
      session_name = argv.fetch(0, options.context.session_name)

      if !session_name
        STDERR.puts "No session in context"
        exit(1)
      end

      Session.new(session_name).attach

    when :list
      data = Session.all.flat_map do |session|
        working_directory = session.get("%sh{pwd}")[0]

        [{ session: session.name, client: nil, buffer_name: nil, working_directory: working_directory }] +

        session.clients.map do |client|
          buffer_name = client.get("%val{bufname}")[0]

          { session: session.name, client: client.name, buffer_name: buffer_name, working_directory: working_directory }
        end
      end

      if options.raw
        text = data.join('\n') do |data|
          data.values.join('\t') do |field|
            field || "null"
          end
        end

        puts text
      else
        print_json(data)
      end

    when :shell
      if !context
        STDERR.puts "No session in context"
        exit(1)
      end

      command, arguments = if argv.any?
        { argv[0], argv[1..] }
      else
        { ENV["SHELL"], [] of String }
      end

      session = options.context.session

      if !session.exists?
        puts "Create the session: #{session.name}"
        session.create
      end

      # Forward session and client options
      environment = {
        "KAKOUNE_SESSION" => options.context.session_name,
        "KAKOUNE_CLIENT" => options.context.client_name
      }

      working_directory = session.get("%sh{pwd}")[0]

      # Start an interactive shell
      Process.run(command, arguments, env: environment, chdir: working_directory, input: :inherit, output: :inherit, error: :inherit)

    when :edit
      if context
        context.fifo(STDIN) unless STDIN.tty?

        return if argv.empty?

        absolute_paths = argv.map do |file|
          Path[file].expand
        end

        context.edit(absolute_paths)
        context.edit(absolute_paths.first, options.position)
      else
        Process.run("kak", [position_option, "--"] + argv, input: :inherit, output: :inherit, error: :inherit)
      end

    when :open
      if context
        return if argv.empty?

        absolute_paths = argv.map do |file|
          Path[file].expand
        end

        context.edit(absolute_paths)
        context.edit(absolute_paths.first, options.position)
      else
        open_client = <<-EOF
          rename-client dummy
          new evaluate-commands -client dummy quit
        EOF

        Process.new("setsid", ["kak", "-ui", "dummy", "-e", open_client, position_option, "--"] + argv)
      end

    when :send
      if !context
        STDERR.puts "No session in context"
        exit(1)
      end

      arguments = CommandConstructor.new

      if argv.any?
        arguments.concat([argv])
      end

      if !STDIN.tty?
        input = STDIN.gets_to_end
        arguments.concat(parse_command_constructor(input)) if input.presence
      end

      debug(options.context, arguments) if options.debug

      command = CommandBuilder.build(arguments)
      context.send(command)

    when :echo
      # Streaming data
      #
      # Example:
      #
      # kcr echo -- evaluate-commands -draft {} |
      # kcr echo -- execute-keys '<a-i>b' 'i<backspace><esc>' 'a<del><esc>' |
      # jq --slurp
      IO.copy(STDIN, STDOUT) unless STDIN.tty?

      if argv.any?
        print_json(argv)
      end

    when :get
      if !context
        STDERR.puts "No session in context"
        exit(1)
      end

      # Streaming data
      #
      # Example:
      #
      # kcr get %val{bufname} |
      # kcr get %val{buflist} |
      # jq --slurp
      IO.copy(STDIN, STDOUT) unless STDIN.tty?

      if argv.any?
        data = context.get(argv)

        if options.raw
          puts data.join('\n')
        else
          print_json(data)
        end
      end

    when :cat
      if !context
        STDERR.puts "No session in context"
        exit(1)
      end

      buffer_contents = if argv.empty?
        [options.context.client.current_buffer.content]
      else
        argv.map { |name| options.context.session.buffer(name).content }
      end

      if options.raw
        puts buffer_contents.join('\n')
      else
        print_json(buffer_contents)
      end

    when :escape
      arguments = CommandConstructor.new

      if argv.any?
        arguments.concat([argv])
      end

      if !STDIN.tty?
        input = STDIN.gets_to_end
        arguments.concat(parse_command_constructor(input)) if input.presence
      end

      puts CommandBuilder.build(arguments)

    when :help
      option_parser.parse(argv + ["--help"])

    else
      # Missing command
      if argv.empty?
        STDERR.puts option_parser
        exit(1)
      end

      # Extending kakoune.cr
      subcommand = argv.shift
      command = "kcr-#{subcommand}"

      # Cannot find executable
      if !Process.find_executable(command)
        STDERR.puts "Cannot find executable: #{command}"
        exit(1)
      end

      # Forward session and client options
      environment = {
        "KAKOUNE_SESSION" => options.context.session_name,
        "KAKOUNE_CLIENT" => options.context.client_name
      }

      # Run subcommand
      Process.run(command, argv, env: environment, input: :inherit, output: :inherit, error: :inherit)
    end
  end

  def install_commands
    command_paths = Dir[RUNTIME_PATH / "commands" / "*" / "kcr-*"]
    bin_path = Path["~/.local/bin"].expand(home: true)

    { command_paths, bin_path.to_s }.tap do |sources, destination|
      Dir.mkdir_p(destination) unless Dir.exists?(destination)
      FileUtils.cp(sources, destination)
      puts "Copied #{sources} to #{destination}"
    end
  end

  def install_desktop_application
    # Download Kakoune logo
    kakoune_logo_install_path = Path[ENV["XDG_DATA_HOME"], "icons/hicolor/scalable/apps/kakoune.svg"]

    { KAKOUNE_LOGO_URL, kakoune_logo_install_path.to_s }.tap do |source, destination|
      status = Process.run("curl", { "-sSL", source, "--create-dirs", "-o", destination })

      if status.success?
        puts "Downloaded #{source} to #{destination}"
      else
        STDERR.puts "Cannot download #{source}"
      end
    end

    # Install the desktop application
    kakoune_desktop_path = RUNTIME_PATH / "applications/kakoune.desktop"
    kakoune_desktop_install_path = Path[ENV["XDG_DATA_HOME"], "applications/kakoune.desktop"]

    { kakoune_desktop_path.to_s, kakoune_desktop_install_path.to_s, kakoune_desktop_install_path.dirname }.tap do |source, destination, directory|
      Dir.mkdir_p(directory) unless Dir.exists?(directory)
      FileUtils.cp(source, destination)
      puts "Copied #{source} to #{destination}"
    end
  end

  def read(part)
    File.read(RUNTIME_PATH / part)
  end

  def print_json(data)
    json = data.to_json

    if STDOUT.tty?
      input = IO::Memory.new(json)
      Process.run("jq", input: input, output: :inherit)
    else
      puts json
    end
  end

  def parse_position(arguments, &block)
    unhandled_arguments = [] of String

    arguments.each do |argument|
      case argument
      when /^[+]([0-9]+)$/
        yield $1.to_i, 0
      when /^[+]([0-9]+):([0-9]+)$/
        yield $1.to_i, $2.to_i
      else
        unhandled_arguments << argument
      end
    end

    arguments.replace(unhandled_arguments)
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
  def parse_command_constructor(json)
    CommandConstructor.from_json(json)
  rescue
    json.each_line.map do |json|
      Array(String).from_json(json)
    end
  end
end

Kakoune::CLI.start(ARGV)
