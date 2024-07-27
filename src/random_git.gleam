import argv
import commands/config
import commands/help
import gleam/dynamic
import gleam/io
import gleam/option
import utils
import utils/config_checks
import utils/toml

pub fn main() {
  let _ =
    toml.parse(
      "
      rootfield = true

      [test]
      a = true

     [test2]
      lt = 1700-12-12T00:00:01
      ",
    )
    |> toml.set_field("test.a", dynamic.from(True))
    |> toml.set_field("test.tessssst", dynamic.from("banana"))
    |> toml.serialize
    |> io.debug
  utils.exit(0)

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
    ["config", "get", "-a"] ->
      config.get(bad_usage: False, raw: False, field: option.None)
    ["config", "get", "--all"] ->
      config.get(bad_usage: False, raw: False, field: option.None)
    ["config", "get", field] ->
      config.get(bad_usage: False, raw: False, field: option.Some(field))
    ["config", "--raw", ..] -> config.help(bad_usage: True, raw: True)
    ["config", ..] -> config.help(bad_usage: True, raw: False)

    ["--raw"] -> help.execute(raw: True, bad_usage: True)
    _ -> help.execute(raw: False, bad_usage: True)
  }
}
