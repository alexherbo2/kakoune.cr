ENV["XDG_DATA_HOME"] ||= Path["~/.local/share"].expand(home: true).to_s
ENV["KCR_RUNTIME"] ||= Path[Process.executable_path.as(String), "../../share/kcr"].expand.to_s
ENV["KCR_DEBUG"] ||= "0"
