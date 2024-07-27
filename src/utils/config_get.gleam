import config
import filepath
import gleam/result
import simplifile
import utils/config_misc

pub fn get_config_file() -> Result(String, String) {
  use config_path <- result.try(config_misc.get_config_path())
  let config_file_path = filepath.join(config_path, config.config_file_name)
  simplifile.read(config_file_path)
  |> result.replace_error("Error: Configuration file not found.")
}
