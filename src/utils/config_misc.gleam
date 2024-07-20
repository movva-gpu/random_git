import filepath
import gleam/option.{None}
import gleamyshell.{home_directory}
import utils.{exit}

pub fn get_config_path() -> String {
  let home_dir: String = case home_directory() {
    Ok(s) -> s
    // 4002 - Home directory is not available
    _ -> exit("Fatal error: Home directory is not available.", None)
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
