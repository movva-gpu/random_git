import config.{config_file_name}
import filepath
import gleam/option.{None}
import simplifile.{Enoent, describe_error, read, read_directory}
import utils.{exit}
import utils/config_create.{create_config_dir, create_config_file}
import utils/config_misc.{get_config_path}

pub fn check_config() -> Nil {
  let config_path: String = get_config_path()

  case read_directory(config_path) {
    Ok(_) -> Nil
    Error(error) ->
      case error {
        Enoent -> create_config_dir(config_path)
        _ ->
          // 4003 - Configuration directory is not available
          exit(
            "Configuration directory is not available:\n  "
              <> describe_error(error)
              <> "\n"
              <> "Configuration path: "
              <> config_path,
            None,
          )
      }
  }
}

pub fn check_config_file() -> Nil {
  let config_path: String = get_config_path()
  let config_file_path: String = filepath.join(config_path, config_file_name)

  case read(config_file_path) {
    Ok(_) -> Nil
    Error(error) ->
      case error {
        Enoent -> create_config_file(config_file_path)
        _ ->
          // Configuration file is not available
          exit(
            "Error: Configuration file is not available:\n  "
              <> describe_error(error)
              <> "\n"
              <> "Configuration file path: "
              <> config_file_path,
            None,
          )
      }
  }
}
