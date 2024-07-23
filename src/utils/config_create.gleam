import simplifile

pub fn create_config_dir(config_path: String) -> Result(Nil, String) {
  case simplifile.create_directory_all(config_path) {
    Ok(_) -> Ok(Nil)
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
  case simplifile.create_file(config_file_path) {
    Ok(_) -> Ok(Nil)

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
