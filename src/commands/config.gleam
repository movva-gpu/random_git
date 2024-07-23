import gleam/io
import tulip
import utils
import utils/color
import utils/commands

pub const name = "config"

pub const description = "Sets or get the value from the configuration"

pub const arguments = [
  commands.InAngleBrackets("set|get"), commands.NoBrackets("category.field"),
  commands.InSquareBrackets("value"),
]

pub fn help(bad_usage usage: Bool, raw raw: Bool) -> Nil {
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
            <> " randomgit "
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
