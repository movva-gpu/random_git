import gleam/io
import argv
import commands/help
import gleam/io
import utils
import utils/config_checks

pub fn main() {
  case utils.check_gh() {
    Ok(_) -> Nil
    Error(err) -> {
      io.println_error(err)
      utils.exit(1)
    }
  }
  case config_checks.check_config_dir() {
    Ok(_) -> Nil
    Error(err) -> {
      io.println_error(err)
      utils.exit(1)
    }
  }
  case config_checks.check_config_file() {
    Ok(_) -> Nil
    Error(err) -> {
      io.println_error(err)
      utils.exit(1)
    }
  }

  case argv.load().arguments {
    ["help"] | ["help", "--help"] -> help.execute(raw: False, bad_usage: False)
    ["help", "--raw"] -> help.execute(raw: True, bad_usage: False)

    ["--raw"] -> help.execute(raw: True, bad_usage: True)
    _ -> help.execute(raw: False, bad_usage: True)
  }
}
