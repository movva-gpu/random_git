import gleam/dynamic
import gleam/float
import gleam/int

@external(javascript, "../toml_ffi.mjs", "toml_parse")
fn parse_toml(toml: String) -> dynamic.Dynamic

pub fn parse(toml: String) -> Result(dynamic.Dynamic, String) {
  let toml = parse_toml(toml)
  case dynamic.string(toml) {
    Error(_) -> Ok(toml)
    Ok(error) ->
      case error {
        "Error: " <> error -> Error("Error: " <> error)
        _ ->
          Error(
            "Error: Unknown error occured when trying to parse the configuration file.",
          )
      }
  }
}

@external(javascript, "../toml_ffi.mjs", "get_toml_field")
fn get_toml_field(toml: dynamic.Dynamic, field: String) -> String

pub fn get_field(
  toml: dynamic.Dynamic,
  field: String,
) -> Result(dynamic.Dynamic, String) {
  case get_toml_field(toml, field) {
    "Error: " <> error -> Error("Error: " <> error)
    value -> {
      case int.parse(value) {
        Ok(int) -> Ok(dynamic.from(int))
        Error(_) ->
          Ok(case float.parse(value) {
            Ok(float) -> dynamic.from(float)
            Error(_) ->
              case value {
                "true" -> dynamic.from(True)
                "false" -> dynamic.from(False)
                _ -> dynamic.from(value)
              }
          })
      }
    }
  }
}

@external(javascript, "../toml_ffi.mjs", "set_toml_field")
fn set_field_toml(
  toml: dynamic.Dynamic,
  field: String,
  value: dynamic.Dynamic,
) -> dynamic.Dynamic

pub fn set_field(
  toml: dynamic.Dynamic,
  field: String,
  value: dynamic.Dynamic,
) -> Result(dynamic.Dynamic, String) {
  let result = set_field_toml(toml, field, value)
  case dynamic.string(result) {
    Ok("Error: " <> error) -> Error("Error: " <> error)
    Ok(_) -> Error("Error: Impossible to set the field " <> field)
    Error(_) -> Ok(result)
  }
}

@external(javascript, "../toml_ffi.mjs", "toml_stringify")
pub fn serialize(toml: dynamic.Dynamic) -> String
