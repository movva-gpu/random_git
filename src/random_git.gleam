import filepath
import gleam/int
import gleam/io
import gleam/option.{type Option, None, Some}
import gleamyshell
import shellout.{exit}
import simplifile.{
  Enoent, create_directory_all, create_file, describe_error, read,
  read_directory,
}
import tom

const config_file_name = "config.toml"

pub fn main() {
  io.println("")

  case gleamyshell.execute("gh", in: ".", args: ["--version"]) {
    Ok(gleamyshell.CommandOutput(0, _)) -> Nil
    Ok(gleamyshell.CommandOutput(code, _)) ->
      io.println("Whoops!\nError (" <> int.to_string(code) <> ")")
    Error(reason) ->
      case reason {
        "enoent" -> crash("Please install gh first")
        _ -> crash("Fatal error while using gh")
      }
  }

  check_config()
  check_config_file()

  exit(0)
}

pub fn quit(reason: Option(String), code: Option(Int)) {
  case reason {
    None -> Nil
    Some(reason) -> io.println(reason)
  }
  case code {
    None -> exit(0)
    Some(error_code) -> exit(error_code)
  }

  panic as "Unreachable code reached, you are god"
}

pub fn crash(reason: String) {
  quit(Some(reason), Some(1))
}

pub fn get_config_path() -> String {
  let home_dir: String = case gleamyshell.home_directory() {
    Ok(s) -> s
    _ -> crash("Fatal error: Home directory is not available")
  }

  case gleamyshell.os() {
    gleamyshell.Windows ->
      home_dir
      |> filepath.join("AppData")
      |> filepath.join("Roaming")
      |> filepath.join("randomgit")
    gleamyshell.Unix(_) ->
      home_dir
      |> filepath.join(".config")
      |> filepath.join("randomgit")
  }
}

pub fn check_config() -> Nil {
  let config_path: String = get_config_path()

  case read_directory(config_path) {
    Ok(_) -> Nil
    Error(error) ->
      case error {
        Enoent -> create_config_dir(config_path)
        _ ->
          crash(
            "Error: Configuration directory is not accessible:\n  "
            <> describe_error(error)
            <> "\n"
            <> "Configuration path: "
            <> config_path,
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
          crash(
            "Error: Configuration file is not accessible:\n  "
            <> describe_error(error)
            <> "\n"
            <> "Configuration file path: "
            <> config_file_path,
          )
      }
  }
}

pub fn create_config_dir(config_path: String) -> Nil {
  io.println("Creating configuration directory...")
  case create_directory_all(config_path) {
    Ok(_) -> io.println("Created configuration directory successfully!")
    Error(error) ->
      crash(
        "Error: Unable to create configuration directory:\n  "
        <> describe_error(error)
        <> "\n"
        <> "Configuration path: "
        <> config_path,
      )
  }
}

pub fn create_config_file(config_file_path: String) -> Nil {
  io.println("Creating configuration file...")
  case create_file(config_file_path) {
    Ok(_) -> io.println("Created configuration file successfully!")
    Error(error) ->
      crash(
        "Error: Unable to create configuration file:\n  "
        <> describe_error(error)
        <> "\n"
        <> "Configuration file path: "
        <> config_file_path,
      )
  }
}
