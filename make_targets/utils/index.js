const { dirSync: tmpDirSync } = require("tmp");
const { sync: rimrafSync } = require("rimraf");
const _ = require("lodash");

const {
  getPostgresConfigurationFilePath,
  getPsqlCredentials,
} = require("./PostgreSQL");

const EVENT_TYPES = [
  "exit",
  "SIGINT",
  "SIGUSR1",
  "SIGUSR2",
  "uncaughtException",
  "SIGTERM",
];

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

module.exports = {
  getPostgresConfigurationFilePath,
  getPsqlCredentials,
  createTmpDir,
};
