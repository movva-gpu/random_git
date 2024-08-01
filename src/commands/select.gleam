import gleam/io
import gleam/list
import gleam/option.{None}
import utils

pub const name = "select"

pub const description = "Selects a repo with the Github CLI or API."

pub const arguments = []

//
// const subcommands = [
//   commands.Command(
//     name: "get",
//     description: "Gets the value of a field in the configuration and prints it.",
//     arguments: [
//       commands.NoBrackets("-a|--all"),
//       commands.InSquareBrackets("category.field"),
//     ],
//     color: color.Lime,
//   ),
//   commands.Command(
//     name: "set",
//     description: "Sets the value of a field in the configuration.",
//     arguments: [
//       commands.NoBrackets("category.field"), commands.InAngleBrackets("value"),
//     ],
//     color: color.Lime,
//   ),
//   commands.Command(
//     name: "list",
//     description: "Lists the available fields in the configuration.",
//     arguments: [],
//     color: color.Lime,
//   ),
// ]

// const options = [
//   commands.FlagOrOption(
//     name: "-a | --all",
//     description: "Use it with get to get all the fields",
//     arguments: [],
//   ),
// ]

/// Possible options:
/// * -h, --help 
/// * -c, --[no-]clone
/// * -f, --[no-]forks
/// * -p, --path [path/to/dir]
/// * --git-opts "-q -b feature/blazingly-fast"
/// * -o, --[no-]open
/// * --[no-]private
/// * --use-api
/// * --use-cli
///
pub fn execute(opts opts: List(String)) -> Nil {
  let #(_help, _clone, _fork, _path, _git_opts, _open, _private, _api) =
    list.index_fold(
      opts,
      #(False, False, False, None, None, False, False, False),
      fn(acc, opt, index) {
        case opt {
          "-h" | "--help" -> #(
            True,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            acc.7,
          )
          "-c" | "--clone" -> #(
            acc.0,
            True,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            acc.7,
          )
          "--no-clone" -> #(
            acc.0,
            False,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            acc.7,
          )
          "-f" | "--forks" -> #(
            acc.0,
            acc.1,
            True,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            acc.7,
          )
          "--no-forks" -> #(
            acc.0,
            acc.1,
            False,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            acc.7,
          )
          "-p" | "--path" -> #(
            acc.0,
            acc.1,
            acc.2,
            utils.list_get(opts, index + 1),
            acc.4,
            acc.5,
            acc.6,
            acc.7,
          )
          "--git-opts" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            utils.list_get(opts, index + 1),
            acc.5,
            acc.6,
            acc.7,
          )
          "-o" | "--open" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            True,
            acc.6,
            acc.7,
          )
          "--no-open" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            False,
            acc.6,
            acc.7,
          )
          "--private" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            True,
            acc.7,
          )
          "--no-private" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            False,
            acc.7,
          )
          "--use-api" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            True,
          )
          "--use-cli" -> #(
            acc.0,
            acc.1,
            acc.2,
            acc.3,
            acc.4,
            acc.5,
            acc.6,
            False,
          )
          val ->
            case val {
              "--" <> _ | "-" -> {
                io.print("Unknown option: " <> val <> "\n")
                utils.exit(1)
              }
              _ -> acc
            }
        }
      },
    )

  Nil
}
