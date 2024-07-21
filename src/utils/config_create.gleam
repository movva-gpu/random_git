import gleam/io
import simplifile

pub fn create_config_dir(config_path: String) -> Result(Nil, String) {
  io.println("Creating configuration directory...")
  case simplifile.create_directory_all(config_path) {
    Ok(_) -> {
      io.println("Created configuration directory successfully!")
      Ok(Nil)
    }
    Error(error) ->
      Error(
        "Error: Unable to create configuration directory:\n  "
        <> simplifile.describe_error(error)
        <> "\n"
        <> "Configuration path: "
        <> config_path,
      )
  }
}

pub fn create_config_file(config_file_path: String) -> Result(Nil, String) {
  io.println("Creating configuration file...")
  case simplifile.create_file(config_file_path) {
    Ok(_) -> {
      io.println("Created configuration file successfully!")
      Ok(Nil)
    }
    Error(error) ->
      Error(
        "Error: Unable to create configuration file:\n  "
        <> simplifile.describe_error(error)
        <> "\n"
        <> "Configuration file path: "
        <> config_file_path,
      )
  }
}
