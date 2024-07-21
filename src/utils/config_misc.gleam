import filepath
import gleam/result
import gleamyshell

pub fn get_config_path() -> Result(String, String) {
  use _ <- result.try_recover(
    gleamyshell.env("XDG_CONFIG_HOME")
    |> result.map(fn (xdg_config_home) { filepath.join(xdg_config_home, "randomgit") })
  )
  use home_dir <- result.try(
    gleamyshell.home_directory()
    |> result.replace_error("Error: Home directory is not available."),
  )
  case gleamyshell.os() {
    gleamyshell.Windows ->
      Ok(
        home_dir
        |> filepath.join("AppData")
        |> filepath.join("Roaming")
        |> filepath.join("randomgit"),
      )
    gleamyshell.Unix(_) ->
      Ok(
        home_dir
        |> filepath.join(".config")
        |> filepath.join("randomgit"),
      )
  }
}
