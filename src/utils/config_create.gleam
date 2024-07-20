import gleam/io
import gleam/option.{None}
import simplifile.{create_directory_all, create_file, describe_error}
import utils.{exit}

pub fn create_config_dir(config_path: String) -> Nil {
  io.println("Creating configuration directory...")
  case create_directory_all(config_path) {
    Ok(_) -> io.println("Created configuration directory successfully!")
    Error(error) ->
      // 5001 - Unable to create configuration directory
      exit(
        "Error: Unable to create configuration directory:\n  "
          <> describe_error(error)
          <> "\n"
          <> "Configuration path: "
          <> config_path,
        None,
      )
  }
}

pub fn create_config_file(config_file_path: String) -> Nil {
  io.println("Creating configuration file...")
  case create_file(config_file_path) {
    Ok(_) -> io.println("Created configuration file successfully!")
    Error(error) ->
      // 5002 - Unable to create configuration file
      exit(
        "Error: Unable to create configuration file:\n  "
          <> describe_error(error)
          <> "\n"
          <> "Configuration file path: "
          <> config_file_path,
        None,
      )
  }
}
