import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import tom
import tulip
import utils
import utils/color
import utils/commands
import utils/config_checks
import utils/config_get

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

  case config_checks.check_config_dir() {
    Ok(_) -> Nil
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  case config_checks.check_config_file() {
    Ok(_) -> Nil
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  let config_file = case config_get.get_config_file() {
    Ok(content) -> content
    Error(error) -> {
      io.println_error(error)
      utils.exit(1)
    }
  }

  let config = case tom.parse(config_file) {
    Ok(parsed) -> parsed
    Error(_) -> {
      io.println_error("Error: TOML parser failed to parse configuration.")
      utils.exit(1)
    }
  }

  case field {
    option.Some(field) -> {
      case string.contains(field, ".") {
        True -> {
          case list.length(string.split(field, ".")) {
            2 -> Nil
            _ ->
              tulip.println(
                color.get_ansi_color_code(color.Red),
                "Error: The field should be formatted in the following way: category.field"
                  <> "\nNot like this: "
                  <> field,
              )
          }
          let category = case list.first(string.split(field, ".")) {
            Ok(category) -> category
            Error(_) -> {
              tulip.println(
                color.get_ansi_color_code(color.Red),
                "Error: The field should be formatted in the following way: category.field"
                  <> "\nNot like this: "
                  <> field,
              )
              utils.exit(1)
            }
          }
          let field = case list.last(string.split(field, ".")) {
            Ok(field) -> field
            Error(_) -> {
              tulip.println(
                color.get_ansi_color_code(color.Red),
                "Error: The field should be formatted in the following way: category.field"
                  <> "\nNot like this: "
                  <> field,
              )
              utils.exit(1)
            }
          }

          case tom.get(config, [category, field]) {
            Ok(value) -> format_toml(value, category, field, False)
            Error(_) -> {
              tulip.println(
                color.get_ansi_color_code(color.Red),
                "Error: The value at "
                  <> category
                  <> "."
                  <> field
                  <> " does not exist.",
              )
              utils.exit(1)
            }
          }
        }
        False -> {
          tulip.println(
            color.get_ansi_color_code(color.Red),
            "Error: The field should be formatted in the following way: category.field"
              <> "\nNot like this: "
              <> field,
          )
          utils.exit(1)
        }
      }
    }
    option.None ->
      case config_file {
        "" -> io.println("Empty configuration file.")
        config -> io.println(config)
      }
  }

  Nil
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

fn format_toml(value: tom.Toml, category: String, field: String, in_array: Bool) {
  case in_array {
    True -> Nil
    False -> io.print(category <> "." <> field <> " -> ")
  }

  case value {
    tom.InlineTable(_) | tom.Table(_) | tom.ArrayOfTables(_) -> {
      io.print_error(
        "Error: Inline Tables and Arrays of Tables are not yet supported.",
      )
    }
    tom.String(value) -> io.print(value)
    tom.Array(value) -> {
      io.print("[ ")
      list.index_map(value, fn(array_value, index) {
        format_toml(array_value, category, field, True)
        case index == list.length(value) - 1 {
          True -> Nil
          False -> io.print(", ")
        }
      })
      io.print(" ]")
    }
    tom.Bool(value) ->
      case value {
        True -> io.print("true")
        False -> io.print("false")
      }
    tom.Date(value) ->
      io.print(
        string.pad_left(int.to_string(value.year), 4, "0")
        <> "-"
        <> string.pad_left(int.to_string(value.month), 2, "0")
        <> "-"
        <> string.pad_left(int.to_string(value.day), 2, "0"),
      )
    tom.DateTime(value) ->
      io.print(
        string.pad_left(int.to_string(value.date.year), 4, "0")
        <> "-"
        <> string.pad_left(int.to_string(value.date.month), 2, "0")
        <> "-"
        <> string.pad_left(int.to_string(value.date.day), 2, "0")
        <> "T"
        <> string.pad_left(int.to_string(value.time.hour), 2, "0")
        <> ":"
        <> string.pad_left(int.to_string(value.time.minute), 2, "0")
        <> ":"
        <> string.pad_left(int.to_string(value.time.second), 2, "0")
        <> case value.offset {
          tom.Local -> ""
          tom.Offset(sign, hours, minutes) -> {
            case sign {
              tom.Positive ->
                "+" <> int.to_string(hours) <> int.to_string(minutes)
              tom.Negative ->
                "-" <> int.to_string(hours) <> int.to_string(minutes)
            }
          }
        },
      )
    tom.Float(value) -> io.print(float.to_string(value))
    tom.Infinity(sign) ->
      io.print(
        case sign {
          tom.Positive -> "+"
          tom.Negative -> "-"
        }
        <> "∞",
      )
    tom.Int(value) -> io.print(int.to_string(value))
    tom.Nan(_) -> io.print("NaN")
    tom.Time(value) ->
      io.print(
        string.pad_left(int.to_string(value.hour), 2, "0")
        <> ":"
        <> string.pad_left(int.to_string(value.minute), 2, "0")
        <> ":"
        <> string.pad_left(int.to_string(value.second), 2, "0"),
      )
  }

  case in_array {
    True -> Nil
    False -> io.print("\n")
  }
}
