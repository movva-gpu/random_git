import gleam/io
import gleam/result
import simplifile
import utils

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

const default_config = "# special values:
# repos = \"default\" -> ~/Repos

[github]

[directories]
repos = \"default\"

[settings]
auto_clone = false
forks = false
"

pub fn create_config_file(config_file_path: String) -> Result(Nil, String) {
  case simplifile.create_file(config_file_path) {
    Ok(_) -> {
      let _ = io.debug(simplifile.read(config_file_path))
      simplifile.write(contents: default_config, to: config_file_path)
      |> io.debug
      |> result.map_error(fn(error) {
        {
          "Error: Unable to write default configuration to its file:\n  "
          <> simplifile.describe_error(error)
          <> "\n"
          <> "  Configuration file path: "
          <> config_file_path
        }
        |> io.println_error

        utils.exit(1)
      })
    }
    Error(error) ->
      Error(
        "Error: Unable to create configuration file:\n  "
        <> simplifile.describe_error(error)
        <> "\n"
        <> "  Configuration file path: "
        <> config_file_path,
      )
  }
}
