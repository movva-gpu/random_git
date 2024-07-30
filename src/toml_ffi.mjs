import TOML from "smol-toml";
import { ToWords } from "to-words";

/**
 * @param {string} toml The **TOML**
 *
 * @returns {object | string} Parsed TOML
 */
export const toml_parse = (toml) => {
  let to_return =
    "Error: An unknown error occurred while trying to parse the configuration file.";
  try {
    to_return = TOML.parse(toml);
  } catch (e) {
    to_return = "Error: Parsing error.";
    if (e instanceof TOML.TomlError) {
      to_return =
        "Error: There is an error in the configuration file on line " +
        e.line +
        "\n\n" +
        e.codeblock
          .split("\n")
          .map((val) => val.padStart(val.length + 2, " "))
          .join("\n") +
        "\n";
    }
  }

  return to_return;
};

const format_array_cb = (val, _index, _arr) => {
  if (typeof val === "string") val = '"' + val + '"';

  if (val instanceof TOML.TomlDate) return val.toISOString();

  if (val instanceof Array) {
    val = val.map(format_array_cb);
    val = "[ " + val.join(", ") + " ]";
  }

  return val;
};

/**
 * @param {object} toml The **TOML**
 * @param {string} field The *field*
 *
 * @returns {any} ***The value***
 */
export const get_toml_field = (toml, field) => {
  const field_arr = field.split(".");

  if (field_arr.length !== 2)
    return "Error: No support for other than two length fields.";

  let to_return;
  try {
    to_return = toml[field_arr[0]][field_arr[1]];
  } catch (_e) {
    return "Error: undefined";
  }

  if (to_return === undefined || to_return === null)
    return "Error: undefined";

  if (typeof to_return === "string") to_return = '"' + to_return + '"';

  if (to_return instanceof TOML.TomlDate) return to_return.toISOString();

  if (to_return instanceof Array) {
    to_return = to_return.map(format_array_cb);
    to_return = "[ " + to_return.join(", ") + " ]";
  }

  return to_return.toString();
};

/**
 * @param {object} toml The **TOML**
 * @param {string} field The *field*
 * @param {any} value ***The value***
 *
 * @returns {object} Parsed TOML
 */
export const set_toml_field = (toml, field, value) => {
  const field_arr = field.split(".");

  if (field_arr.length !== 2)
    return (
      "Error: No support for other than two levels deep fields.\n" +
      "       The field " +
      field +
      " is " +
      new ToWords({
        localeCode: "en-IN",
        converterOptions: {
          ignoreDecimal: false,
          ignoreZeroCurrency: false,
        },
      })
        .convert(field_arr.length)
        .toLowerCase() +
      " " +
      (field_arr.length === 1 ? "level" : "levels") +
      " deep."
    );

  try {
    toml[field_arr[0]][field_arr[1]] = new TOML.TomlDate(
      Date.parse(value),
    ).toISOString();
  } catch (_err) {
    toml[field_arr[0]] = toml[field_arr[0]] ?? {};
    toml[field_arr[0]][field_arr[1]] = value;
  }

  return toml;
};

export const toml_stringify = TOML.stringify;
