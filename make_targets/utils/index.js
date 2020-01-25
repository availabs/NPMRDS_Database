const { join } = require('path');
const { dirSync: tmpDirSync } = require('tmp');
const { sync: rimrafSync } = require('rimraf');
const _ = require('lodash');

const EVENT_TYPES = [
  'exit',
  'SIGINT',
  'SIGUSR1',
  'SIGUSR2',
  'uncaughtException',
  'SIGTERM'
];

const getPostgresConfigurationFilePath = pg_env =>
  join(
    __dirname,
    pg_env === 'production'
      ? '../../config/postgres.env.prod'
      : '../../config/postgres.env.dev'
  );

const createTmpDir = () => {
  const { name } = tmpDirSync({ unsafeCleanup: true });

  let cleanup = () => rimrafSync(name);

  // https://stackoverflow.com/a/49392671/3970755
  EVENT_TYPES.forEach(eventType => {
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
  createTmpDir
};
