// import commands/config
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, Some}
import gleam/string
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
  // commands.Command(
//   name: config.name,
//   description: config.description,
//   arguments: config.arguments,
//   color: color.Aqua,
// ),
]

pub const all_global_flags = [
  commands.GlobalFlag(
    name: "--raw",
    description: "Prints the output of a function without formatting, or \"useless\" data.",
    arguments: [],
  ),
  commands.GlobalFlag(
    name: "--help",
    description: "Prints help for the given command.",
    arguments: [],
  ),
]

pub fn execute(raw raw: Bool, bad_usage usage: Bool) -> Nil {
  case raw {
    False -> {
      tulip.print(10, "Random Git")
      color.println_dim(" (current version: N/A)\n")
    }
    True -> Nil
  }
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
    print_formatted_command(
      command.name,
      Some(command.color),
      command.arguments,
      command.description,
      raw,
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
    print_formatted_global_flag(
      global_flag.name,
      Some(color.Lime),
      global_flag.arguments,
      global_flag.description,
      raw,
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

fn print_formatted_command(
  name: String,
  cl: Option(color.AnsiColor),
  args: List(commands.Argument),
  msg: String,
  raw: Bool,
) {
  let cl_code =
    cl
    |> option.unwrap(color.Aqua)
    |> color.get_ansi_color_code

  case raw {
    False -> {
      io.print("  ")
      tulip.print(cl_code, string.pad_right(name, get_command_length(), " "))
      print_formatted_arguments(args, raw)
      io.println(msg)
    }
    True -> {
      io.print(name)
      io.print(" ")
      print_formatted_arguments(args, raw)
      io.print(" ")
      io.println(msg)
    }
  }
}

fn print_formatted_global_flag(
  name: String,
  cl: Option(color.AnsiColor),
  args: List(commands.Argument),
  msg: String,
  raw: Bool,
) {
  let cl_code =
    cl
    |> option.unwrap(color.Aqua)
    |> color.get_ansi_color_code

  case raw {
    False -> {
      io.print("  ")
      tulip.print(
        color.get_darker_color_code(cl_code),
        color.dim_text("<command>"),
      )
      io.print(" ")
      tulip.print(
        cl_code,
        string.pad_right(
          name,
          get_command_length() |> int.subtract(string.length("<command> ")),
          " ",
        ),
      )
      print_formatted_arguments(args, raw)
      io.println(msg)
    }
    True -> {
      io.print(name)
      io.print(" ")
      print_formatted_arguments(args, raw)
      io.print(" ")
      io.println(msg)
    }
  }
}

fn get_command_length() {
  all_commands
  |> list.map(fn(command) { command.name })
  |> list.append(
    all_global_flags
    |> list.map(fn(flag) { "<command> " <> flag.name }),
  )
  |> list.map(string.length)
  |> list.fold(0, int.max)
  |> int.add(4)
}

fn get_arguments_length() {
  all_commands
  |> list.map(fn(command) { command.arguments })
  |> list.map(fn(arguments) {
    list.index_fold(arguments, 0, fn(length, argument, index) {
      length + string.length(argument.name)
      |> int.add(case argument {
        commands.InAngleBrackets(_) | commands.InSquareBrackets(_) -> 2
      })
      |> int.add(case index == list.length(arguments) - 1 {
        False -> 1
        True -> 0
      })
    })
  })
  |> list.append(
    all_global_flags
    |> list.map(fn(command) { command.arguments })
    |> list.map(fn(arguments) {
      list.index_fold(arguments, 0, fn(length, argument, index) {
        case argument {
          commands.InAngleBrackets(argument) ->
            length + string.length(argument) + 2
          commands.InSquareBrackets(argument) ->
            length + string.length(argument) + 2
        }
        |> int.add(case index == list.length(arguments) - 1 {
          False -> 1
          True -> 0
        })
      })
    }),
  )
  |> list.fold(0, int.max)
  |> int.add(4)
}

fn print_formatted_arguments(args: List(commands.Argument), raw: Bool) {
  let length = get_arguments_length()
  let arg_length =
    list.fold(
      args
        |> list.map(fn(arg) {
          case arg {
            commands.InAngleBrackets(arg) -> "<" <> arg <> ">"
            commands.InSquareBrackets(arg) -> "[" <> arg <> "]"
          }
        })
        |> list.index_map(fn(arg, index) {
          case index == list.length(args) - 1 {
            False -> arg <> " "
            True -> arg
          }
        }),
      0,
      fn(length, arg) {
        case raw {
          False -> {
            color.print_dim(arg)
            length
            |> int.add(string.length(arg))
          }
          True -> {
            io.print(arg)
            0
          }
        }
      },
    )

  io.print(string.repeat(" ", length - arg_length))
}
