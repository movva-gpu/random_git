/**
 * Terminates the current process with the specified exit code.
 *
 * @param {number} code - The exit code to use.
 * @return {void} This function does not return anything.
 */
export function os_exit(code) {
  process.exit(code);
}
