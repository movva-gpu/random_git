import gleam/io
import utils.{check_gh, exit}
import utils/config_checks.{check_config_dir, check_config_file}

// import argv

pub fn main() {
  io.println("")

  case check_gh() {
    Ok(_) -> Nil
    Error(err) -> {
      io.println_error(err)
      exit(1)
    }
  }

  case check_config_dir() {
    Ok(_) -> Nil
    Error(err) -> {
      io.println_error(err)
      exit(1)
    }
  }
  case check_config_file() {
    Ok(_) -> Nil
    Error(err) -> {
      io.println_error(err)
      exit(1)
    }
  }
}
