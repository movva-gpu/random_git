import gleam/dynamic
import gleam/float
import gleam/int

@external(javascript, "../toml_ffi.mjs", "toml_parse")
pub fn parse(toml: String) -> dynamic.Dynamic

@external(javascript, "../toml_ffi.mjs", "get_toml_field")
fn get_toml_field(toml: dynamic.Dynamic, field: String) -> String

@external(javascript, "../toml_ffi.mjs", "set_toml_field")
pub fn set_field(
  toml: dynamic.Dynamic,
  field: String,
  value: dynamic.Dynamic,
) -> dynamic.Dynamic

@external(javascript, "../toml_ffi.mjs", "toml_stringify")
pub fn serialize(toml: dynamic.Dynamic) -> String

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
