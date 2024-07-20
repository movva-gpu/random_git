import gleam/io
import utils.{check_gh}
import utils/config_checks.{check_config, check_config_file}
// import argv

pub fn main() {
  io.println("")

  check_gh()

  check_config()
  check_config_file()
}
