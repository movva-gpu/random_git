import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option}
import gleam/string
import tulip
import utils/color

pub type Argument {
  InAngleBrackets(name: String)
  InSquareBrackets(name: String)
  NoBrackets(name: String)
}

pub type Command {
  Command(
    name: String,
    description: String,
    arguments: List(Argument),
    color: color.AnsiColor,
  )
}

pub type FlagOrOption {
  FlagOrOption(name: String, description: String, arguments: List(Argument))
}

pub fn print_formatted_command(
  name: String,
  cl: Option(color.AnsiColor),
  args: List(Argument),
  msg: String,
  raw: Bool,
  commands: List(Command),
  flags: List(FlagOrOption),
  is_global_flags: Bool,
) {
  let cl_code =
    cl
    |> option.unwrap(color.Aqua)
    |> color.get_ansi_color_code

  case raw {
    False -> {
      io.print("  ")
      tulip.print(
        cl_code,
        string.pad_right(
          name,
          get_command_length(commands, flags, is_global_flags),
          " ",
        ),
      )
      print_formatted_arguments(args, raw, commands, flags)
      io.println(msg)
    }
    True -> {
      io.print(name)
      io.print(" ")
      print_formatted_arguments(args, raw, commands, flags)
      io.print("  ")
      io.println(msg)
    }
  }
}

pub fn print_formatted_global_flag(
  name: String,
  cl: Option(color.AnsiColor),
  args: List(Argument),
  msg: String,
  raw: Bool,
  commands: List(Command),
  flags: List(FlagOrOption),
  is_global_flags: Bool,
) {
  let cl_code =
    cl
    |> option.unwrap(color.Aqua)
    |> color.get_ansi_color_code

  case raw {
    False -> {
      io.print("  ")
      case is_global_flags {
        True -> {
          tulip.print(
            color.get_darker_color_code(cl_code),
            color.dim_text("<command>"),
          )
          io.print(" ")
        }
        False -> Nil
      }
      tulip.print(
        cl_code,
        string.pad_right(
          name,
          case is_global_flags {
            True ->
              get_command_length(commands, flags, is_global_flags)
              |> int.subtract(string.length("<command> "))
            False -> get_command_length(commands, flags, is_global_flags)
          },
          " ",
        ),
      )
      print_formatted_arguments(args, raw, commands, flags)
      io.println(msg)
    }
    True -> {
      io.print(name)
      io.print(" ")
      print_formatted_arguments(args, raw, commands, flags)
      io.print(" ")
      io.println(msg)
    }
  }
}

fn get_command_length(
  commands: List(Command),
  flags: List(FlagOrOption),
  is_global_flags: Bool,
) {
  commands
  |> list.map(fn(command) { command.name })
  |> list.append(
    flags
    |> list.map(fn(flag) {
      case is_global_flags {
        True -> "<command> " <> flag.name
        False -> flag.name
      }
    }),
  )
  |> list.map(string.length)
  |> list.fold(0, int.max)
  |> int.add(2)
}

fn get_arguments_length(commands: List(Command), flags: List(FlagOrOption)) {
  commands
  |> list.map(fn(command) { command.arguments })
  |> list.map(fn(arguments) {
    list.index_fold(arguments, 0, fn(length, argument, index) {
      length + string.length(argument.name)
      |> int.add(case argument {
        InAngleBrackets(_) | InSquareBrackets(_) -> 2
        NoBrackets(_) -> 0
      })
      |> int.add(case index == list.length(arguments) - 1 {
        False -> 1
        True -> 0
      })
    })
  })
  |> list.append(
    flags
    |> list.map(fn(command) { command.arguments })
    |> list.map(fn(arguments) {
      list.index_fold(arguments, 0, fn(length, argument, index) {
        length + string.length(argument.name)
        |> int.add(case argument {
          InAngleBrackets(_) | InSquareBrackets(_) -> 2
          NoBrackets(_) -> 0
        })
        |> int.add(case index == list.length(arguments) - 1 {
          False -> 1
          True -> 0
        })
      })
    }),
  )
  |> list.fold(0, int.max)
  |> int.add(2)
}

fn print_formatted_arguments(
  args: List(Argument),
  raw: Bool,
  commands: List(Command),
  flags: List(FlagOrOption),
) {
  let length = get_arguments_length(commands, flags)
  let arg_length =
    list.fold(
      args
        |> list.map(fn(arg) {
          case arg {
            InAngleBrackets(arg) -> "<" <> arg <> ">"
            InSquareBrackets(arg) -> "[" <> arg <> "]"
            NoBrackets(arg) -> arg
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

  case raw {
    False -> io.print(string.repeat(" ", length - arg_length))
    True -> Nil
  }
}
