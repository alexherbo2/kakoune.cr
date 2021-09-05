require "./lib"

class Kakoune::Process < Process
  def self.setsid(command, arguments)
    fork do
      C.setsid

      # Double fork to orphan the server.
      # https://github.com/mawww/kakoune/blob/master/src/main.cc#:~:text=fork_server_to_background
      fork do
        new(command, arguments)
      end
    end
  end
end
