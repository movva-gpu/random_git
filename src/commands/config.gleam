import config
import filepath
import gleam/dynamic
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import simplifile
import tulip
import utils
import utils/color
import utils/commands
import utils/config_get
import utils/config_misc
import utils/toml

pub const name = "config"

pub const description = "Sets or get the value from the configuration"

pub const arguments = [
  commands.InAngleBrackets("set|get|list"),
  commands.NoBrackets("category.field"), commands.InSquareBrackets("value"),
]

const subcommands = [
  commands.Command(
    name: "get",
    description: "Gets the value of a field in the configuration and prints it.",
    arguments: [
      commands.NoBrackets("-a|--all"),
      commands.InSquareBrackets("category.field"),
    ],
    color: color.Lime,
  ),
  commands.Command(
    name: "set",
    description: "Sets the value of a field in the configuration.",
    arguments: [
      commands.NoBrackets("category.field"), commands.InAngleBrackets("value"),
    ],
    color: color.Lime,
  ),
  commands.Command(
    name: "list",
    description: "Lists the available fields in the configuration.",
    arguments: [],
    color: color.Lime,
  ),
]

const options = [
  commands.FlagOrOption(
    name: "-a | --all",
    description: "Use it with get to get all the fields",
    arguments: [],
  ),
]

pub fn help(bad_usage usage: Bool, raw raw: Bool) -> Nil {
  utils.hello_message(raw)
  print_bad_usage(usage, raw)

  case raw {
    False -> {
      tulip.print(color.get_ansi_color_code(color.Lime), "Description")
      color.print_dim(":")
      io.print(" ")
      io.println(description)
      io.print("\n")

      print_usage(raw)

      tulip.print(color.get_ansi_color_code(color.Lime), "Commands")
      color.println_dim(":")
    }
    True -> io.println("Commands:")
  }

  list.each(subcommands, fn(command) {
    commands.print_formatted_command(
      command.name,
      option.Some(command.color),
      command.arguments,
      command.description,
      raw,
      subcommands,
      options,
      False,
    )
  })

  case raw {
    False -> {
      io.println("")
      tulip.print(color.get_ansi_color_code(color.Silver), "Options")
      color.print_dim(":")
      io.println(" ")
    }
    True -> io.println("Options:")
  }

  list.each(options, fn(option) {
    commands.print_formatted_global_flag(
      option.name,
      option.Some(color.Silver),
      option.arguments,
      option.description,
      raw,
      subcommands,
      options,
      False,
    )
  })
}

pub fn get(
  bad_usage usage: Bool,
  raw raw: Bool,
  field field: option.Option(String),
) -> Nil {
  utils.hello_message(raw)
  print_bad_usage(usage, raw)

  let file_content = case config_get.get_config_file() {
    Ok(content) -> content
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  let field = case field {
    option.Some(field) -> field
    option.None -> {
      tulip.println(color.get_ansi_color_code(color.Yellow), file_content)
      utils.exit(0)
    }
  }

  let parsed = case toml.parse(file_content) {
    Ok(parsed) -> parsed
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  case toml.get_field(parsed, field) {
    Ok(value) -> {
      case dynamic.int(value) {
        Ok(value) -> io.println(int.to_string(value))
        Error(_) ->
          case dynamic.float(value) {
            Ok(value) -> io.println(float.to_string(value))
            Error(_) ->
              case dynamic.bool(value) {
                Ok(True) -> io.println("true")
                Ok(False) -> io.println("false")
                Error(_) ->
                  case dynamic.string(value) {
                    Ok(value) -> io.println(value)
                    Error(_) ->
                      io.println(
                        "Error: Something wrong occured while decoding the value.",
                      )
                  }
              }
          }
      }
    }
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }
}

pub fn set(
  bad_usage usage: Bool,
  raw raw: Bool,
  field field: String,
  value value: String,
) -> Nil {
  utils.hello_message(raw)
  print_bad_usage(usage, raw)

  let file_content = case config_get.get_config_file() {
    Ok(content) -> content
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  let parsed = case toml.parse(file_content) {
    Ok(parsed) -> parsed
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  let toml =
    parsed
    |> toml.set_field(field, value)
    |> result.map_error(fn(error) {
      io.println_error(error)
      utils.exit(1)
    })
    |> result.unwrap(parsed)
    |> toml.serialize

  case
    result.try(config_misc.get_config_path(), fn(config_path) {
      simplifile.write(
        contents: toml,
        to: filepath.join(config_path, config.config_file_name),
      )
      |> result.map_error(fn(error) {
        "Error: Unable to write the new contents to the configuration file."
        <> "\n"
        <> "  Reason: "
        <> simplifile.describe_error(error)
        <> "  Configuration file path: "
        <> config_path
      })
    })
  {
    Ok(_) -> io.println("Done!")
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }
}

fn print_bad_usage(usage: Bool, raw: Bool) -> Nil {
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
            command <> " randomgit config ",
          )

          tulip.print(color.get_ansi_color_code(color.Blue), "[...flags] ")

          io.println(
            "<set|get> category.field [value] "
            <> color.dim_text("[...options]\n"),
          )

          tulip.print(color.get_ansi_color_code(color.Lime), "Hints")
          io.println(
            color.dim_text(":")
            <> "\n  - Run "
            <> command
            <> " randomgit help to get all commands!\n"
            <> "  - You can also run "
            <> command
            <> " randomgit config "
            <> color.dim_text("--help")
            <> "!",
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
}

pub fn print_usage(raw: Bool) {
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
      io.print("Usage: " <> color.dim_text("$") <> " ")
      tulip.print(
        color.get_ansi_color_code(color.Aqua),
        command <> " randomgit config ",
      )

      tulip.print(color.get_ansi_color_code(color.Blue), "[...flags] ")

      io.println(
        "<command> [...arguments] " <> color.dim_text("[...options]\n"),
      )
    }
    True -> Nil
  }
}
