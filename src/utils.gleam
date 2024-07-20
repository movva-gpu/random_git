import gleam/io
import gleam/option.{type Option, None, Some}
import gleamyshell.{which}

pub fn check_gh() -> Nil {
  case which("gh") {
    Ok(_) -> Nil
    Error(_) ->
      // 4001 - Github CLI not found.
      exit(
        "Error: Github CLI not found.\nPlease install gh first: \n"
          <> "https://github.com/cli/cli#installation",
        None,
      )
  }
}

pub fn exit(message: String, panic_message: Option(String)) -> a {
  io.println_error(message)
  case panic_message {
    Some(pm) -> panic as pm
    None -> panic
  }
}
