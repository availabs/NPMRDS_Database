const { readFileSync } = require("fs");
const { join } = require("path");

const { dirSync: tmpDirSync } = require("tmp");
const { sync: rimrafSync } = require("rimraf");
const _ = require("lodash");
const dotenv = require("dotenv");

const PostgresEnvVariables = require("./PostgresEnvVariables");

const EVENT_TYPES = [
  "exit",
  "SIGINT",
  "SIGUSR1",
  "SIGUSR2",
  "uncaughtException",
  "SIGTERM",
];

const getPostgresConfigurationFilePath = (pg_env) =>
  join(
    __dirname,
    pg_env === "production"
      ? "../../config/postgres.env.prod"
      : "../../config/postgres.env.dev"
  );

const createTmpDir = () => {
  const { name } = tmpDirSync({ unsafeCleanup: true });

  let cleanup = () => rimrafSync(name);

  // https://stackoverflow.com/a/49392671/3970755
  EVENT_TYPES.forEach((eventType) => {
    process.on(eventType, () => {
      try {
        const f = cleanup;
        cleanup = _.noop;

        f();
      } catch (err) {
        //
      }
    });
  });

  return name;
};

const getPsqlCredentials = (pgEnv) => {
  const configPath = getPostgresConfigurationFilePath(pgEnv);
  const configContents = readFileSync(configPath);

  const envVars = dotenv.parse(configContents);

  return _.pick(envVars, Object.keys(PostgresEnvVariables));
};

module.exports = {
  getPostgresConfigurationFilePath,
  getPsqlCredentials,
  createTmpDir,
};
