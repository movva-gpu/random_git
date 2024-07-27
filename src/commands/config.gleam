import config
import filepath
import gleam/dynamic
import gleam/float
import gleam/int
import gleam/io
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
  commands.InAngleBrackets("set|get"), commands.NoBrackets("category.field"),
  commands.InSquareBrackets("value"),
]

pub fn help(bad_usage usage: Bool, raw raw: Bool) -> Nil {
  utils.hello_message(raw)
  bad_usage(usage, raw)
}

pub fn get(
  bad_usage usage: Bool,
  raw raw: Bool,
  field field: option.Option(String),
) -> Nil {
  utils.hello_message(raw)
  bad_usage(usage, raw)

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
  bad_usage(usage, raw)

  let file_content = case config_get.get_config_file() {
    Ok(content) -> content
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  let toml =
    case toml.parse(file_content) {
      Ok(parsed) -> parsed
      Error(error) -> {
        io.println_error(error)
        utils.exit(1)
      }
    }
    |> toml.set_field(field, dynamic.from(value))
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

fn bad_usage(usage: Bool, raw: Bool) -> Nil {
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
