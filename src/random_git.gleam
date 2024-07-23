import argv
import commands/config
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

    ["config", "--help"] -> config.help(bad_usage: False, raw: False)
    ["config", "--help", "--raw"] | ["config", "--raw", "--help"] ->
      config.help(bad_usage: False, raw: True)
    ["config", "--raw", ..] -> config.help(bad_usage: True, raw: True)
    ["config", ..] -> config.help(bad_usage: True, raw: False)

    ["--raw"] -> help.execute(raw: True, bad_usage: True)
    _ -> help.execute(raw: False, bad_usage: True)
  }
}
