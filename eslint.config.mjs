import globals from "globals";
import pluginJs from "@eslint/js";

/** @type {import("eslint").Linter.Config} */
export default [
  { languageOptions: { globals: globals.node } },
  pluginJs.configs.recommended,
  {
    rules: {
      semi: "error",
      "prefer-const": "warn",
      "no-unused-vars": [
        "warn",
        {
          varsIgnorePattern: "^_.*$",
          argsIgnorePattern: "^_.*$",
          caughtErrorsIgnorePattern: "^_.*$",
          destructuredArrayIgnorePattern: "^_.*$",
        },
      ],
    },
  },
];
