import argv
import commands/help

pub fn main() {

  case argv.load().arguments {
    ["help"] | ["help", "--help"] -> help.execute(raw: False, bad_usage: False)
    ["help", "--raw"] -> help.execute(raw: True, bad_usage: False)

    ["--raw"] -> help.execute(raw: True, bad_usage: True)
    _ -> help.execute(raw: False, bad_usage: True)
  }
}
