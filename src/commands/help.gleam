import color
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, Some}
import gleam/string
import tulip
import utils
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
      io.print("\t")
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
          get_command_length() |> int.subtract(string.length("<command>")),
          " ",
        ),
      )
      print_formatted_arguments(args, raw)
      io.print("\t")
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
    |> list.map(fn(flag) { "<command>" <> flag.name }),
  )
  |> list.map(string.length)
  |> list.fold(0, int.max)
  |> int.add(15)
}

fn print_formatted_arguments(args: List(commands.Argument), raw: Bool) {
  use arg <- list.each(args)
  case arg {
    commands.Mandatory(arg) -> {
      case raw {
        False -> tulip.print(0, "<" <> arg <> ">")
        True -> io.print("<" <> arg <> ">")
      }
    }
    commands.Optional(arg) -> {
      case raw {
        False -> tulip.print(0, "[" <> arg <> "]")
        True -> io.print("[" <> arg <> "]")
      }
    }
  }
}
