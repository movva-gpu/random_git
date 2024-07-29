import argv
import gleam/result
import gleam/string
import gleamyshell
import tulip
import utils/color

pub fn check_gh() -> Result(Nil, String) {
  gleamyshell.which("gh")
  |> result.replace_error(
    "Error: Github CLI not found.\nPlease install gh first: \n"
    <> "https://github.com/cli/cli#installation",
  )
  |> result.replace(Nil)
}

pub fn gh_version() -> Result(String, String) {
  case gleamyshell.execute("gh", ".", ["--version"]) {
    Ok(gleamyshell.CommandOutput(0, version)) -> {
      Ok(version)
    }
    _ ->
      Error(
        "Error: Github CLI not found.\nPlease install gh first: \n"
        <> "https://github.com/cli/cli#installation",
      )
  }
}

pub type Runtime {
  Bun
  Node
}

pub fn current_runtime() -> Result(Runtime, String) {
  case string.contains(argv.load().runtime, "bun") {
    True -> Ok(Bun)
    False ->
      case string.contains(argv.load().runtime, "node") {
        True -> Ok(Node)
        False -> Error("Error: You must run randomgit with bunx, or npx")
      }
  }
}

@external(javascript, "./exit_ffi.mjs", "os_exit")
pub fn exit(code: Int) -> a

pub fn hello_message(raw: Bool) -> Nil {
  case raw {
    False -> {
      tulip.print(color.get_ansi_color_code(color.Fuchsia), "Random Git")
      color.println_dim(" (current version: N/A)\n")
    }
    True -> Nil
  }
}
