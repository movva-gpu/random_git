import config.{config_file_name}
import filepath
import gleam/result
import simplifile
import utils/config_create.{create_config_dir, create_config_file}
import utils/config_misc.{get_config_path}

/// Thanks to [@lpil](https://github.com/lpil)(the code is basically written by him),
/// [@hayleigh.dev](https://github.com/hayleigh-dot-dev), and some other people for the huge help
/// on the Gleam Discord server understanding Gleam better.
/// 
/// And thanks to [Erika Rowland](https://erikarow.land/) for her amazing
/// article ['Using `use` in Gleam'](https://erikarow.land/notes/using-use-gleam).
///
pub fn check_config_dir() -> Result(Nil, String) {
  use config_path <- result.try(get_config_path())
  use is_directory <- result.try(
    simplifile.is_directory(config_path)
    |> result.map_error(fn(error) { simplifile.describe_error(error) }),
  )
  case is_directory {
    True -> Ok(Nil)
    False -> create_config_dir(config_path)
  }
}

pub fn check_config_file() -> Result(Nil, String) {
  use config_path <- result.try(get_config_path())
  let config_file_path = filepath.join(config_path, config_file_name)
  use is_file <- result.try(
    simplifile.is_file(config_file_path)
    |> result.map_error(fn(error) { simplifile.describe_error(error) }),
  )
  case is_file {
    True -> Ok(Nil)
    False -> create_config_file(config_file_path)
  }
}
