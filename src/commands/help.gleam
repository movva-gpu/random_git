import commands/config
import commands/select
import gleam/io
import gleam/list
import gleam/option.{Some}
import tulip
import utils
import utils/color
import utils/commands

pub const name = "help"

pub const description = "Prints this text"

pub const all_commands = [
  commands.Command(
    name: name,
    description: description,
    arguments: [],
    color: color.Aqua,
  ),
  commands.Command(
    name: config.name,
    description: config.description,
    arguments: config.arguments,
    color: color.Aqua,
  ),
  commands.Command(
    name: select.name,
    description: select.description,
    arguments: select.arguments,
    color: color.Aqua,
  ),
]

pub const all_global_flags = [
  commands.FlagOrOption(
    name: "--raw",
    description: "Prints the output of a function without formatting, or \"useless\" data.",
    arguments: [],
  ),
  commands.FlagOrOption(
    name: "--help",
    description: "Prints help for the given command.",
    arguments: [],
  ),
]

pub fn execute(raw raw: Bool, bad_usage usage: Bool) -> Nil {
  utils.hello_message(raw)
  case usage {
    True -> {
      let command = case utils.current_runtime() {
        Ok(utils.Bun) -> "bunx"
        Ok(utils.Node) -> "npx"
        Error(error) -> {
          io.println_error(error)
          utils.exit(1)
        }
      }
      case raw {
        False -> {
          tulip.print(color.get_ansi_color_code(color.Red), "Error")
          io.println(color.dim_text(":") <> " Bad usage\n")

          io.print("Usage: " <> color.dim_text("$") <> " ")
          tulip.print(
            color.get_ansi_color_code(color.Aqua),
            command <> " randomgit " <> color.dim_text("<command>") <> " ",
          )
          tulip.print(color.get_ansi_color_code(color.Blue), "[...flags]")
          io.println(" " <> color.dim_text("[...options]") <> "\n")

          tulip.print(color.get_ansi_color_code(color.Lime), "Hint")
          io.println(
            color.dim_text(":")
            <> " Run "
            <> command
            <> " randomgit help to get all commands!",
          )
        }
        True ->
          io.println(
            "Error: Bad usage"
            <> "\n"
            <> "Usage: "
            <> command
            <> " random git <command> [...flags] [...options]",
          )
      }
      utils.exit(1)
    }
    False -> Nil
  }

  case raw {
    False ->
      tulip.println(
        color.get_ansi_color_code(color.Aqua),
        "Available commands:",
      )
    True -> Nil
  }

  list.each(all_commands, fn(command) {
    commands.print_formatted_command(
      command.name,
      Some(command.color),
      command.arguments,
      command.description,
      raw,
      all_commands,
      all_global_flags,
      True,
    )
  })

  case raw {
    False -> {
      io.println("")
      tulip.print(
        color.get_ansi_color_code(color.Green),
        "Available global flags: ",
      )
      color.println_dim("(flags that can be used with any command)")
    }
    True -> Nil
  }

  list.each(all_global_flags, fn(global_flag) {
    commands.print_formatted_global_flag(
      global_flag.name,
      Some(color.Lime),
      global_flag.arguments,
      global_flag.description,
      raw,
      all_commands,
      all_global_flags,
      True,
    )
  })

  case utils.gh_version() {
    Ok(version) ->
      case raw {
        False -> {
          io.println("")
          color.print_dim("Using " <> version)
        }
        True -> Nil
      }
    Error(error) -> {
      io.print_error(error)
      utils.exit(1)
    }
  }
}
