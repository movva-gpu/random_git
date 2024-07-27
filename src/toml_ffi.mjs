import TOML from "smol-toml";

export const toml_parse = TOML.parse;

/**
 * @param {any} toml
 * @param {string} field
 *
 * @returns {any}
 */
export const get_toml_field = (toml, field) => {
  let field_arr = field.split(".");

  if (field_arr.length !== 2)
    return "Error: No support for other than two length fields.";

  let to_return = toml[field_arr[0]][field_arr[1]];

  if (to_return === undefined || to_return === null)
    return "Error: Field does not exist";

  if (to_return instanceof TOML.TomlDate) return to_return.toISOString();

  return to_return.toString();
};

/**
 * @param {any} toml
 * @param {string} field
 * @param {any} value
 *
 * @returns {any}
 */
export const set_toml_field = (toml, field, value) => {
  let field_arr = field.split(".");

  if (field_arr.length !== 2)
    return "Error: No support for other than two length fields.";

  try {
    toml[field_arr[0]][field_arr[1]] = new TOML.TomlDate(
      TOML.TomlDate.parse(value),
    ).toISOString();
  } catch (_err) {
    toml[field_arr[0]][field_arr[1]] = value;
  }

  return toml;
};

export const toml_stringify = TOML.stringify;
