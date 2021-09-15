module.exports = {
  extends: ["prettier", "plugin:prettier/recommended"],
  parser: "@typescript-eslint/parser",
  parserOptions: {
    project: "tsconfig.eslint.json",
  },
  plugins: ["import", "prettier", "@typescript-eslint"],
  rules: {
    "@typescript-eslint/naming-convention": "off",
    camelcase: "off",
    "no-console": "off",
    "no-continue": "off",
    "no-underscore-dangle": "off",
    "no-param-reassign": "off",
    "no-plusplus": "off",
    "import/extensions": [
      "error",
      "ignorePackages",
      {
        js: "never",
        ts: "never",
      },
    ],
    "prettier/prettier": ["error"],
  },
  settings: {
    "import/parsers": {
      "@typescript-eslint/parser": ["js", "ts"],
    },
    "import/resolver": {
      node: {
        extensions: [".js", ".ts", ".json"],
      },
    },
  },
};
