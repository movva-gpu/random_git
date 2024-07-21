import gleam/result
import gleamyshell

pub fn check_gh() -> Result(Nil, String) {
  gleamyshell.which("gh")
  |> result.replace_error(
    "Error: Github CLI not found.\nPlease install gh first: \n"
    <> "https://github.com/cli/cli#installation",
  )
  |> result.replace(Nil)
}

@external(javascript, "./exit_ffi.mjs", "os_exit")
pub fn exit(code: Int) -> Nil
