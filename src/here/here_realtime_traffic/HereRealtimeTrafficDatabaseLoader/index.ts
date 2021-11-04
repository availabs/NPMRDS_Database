import { spawn, execSync } from "child_process";
import EventEmitter from "events";
import { readFileSync } from "fs";
import { pipeline } from "stream";
import { join, basename } from "path";
import memoizeOne from "memoize-one";
import through from "through2";

import dotenv from "dotenv";
import _ from "lodash";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";

import createHereRealtimeTrafficCsvStreamChain from "./utils/createHereRealtimeTrafficCsvStreamChain";

import hereRealtimeTrafficDatabaseTableColumns from "./utils/hereRealtimeTrafficDatabaseTableColumns";

import { PGEnv } from "../types";

const sqlDir = join(__dirname, "../../../../sql/here_realtime_traffic");

const loadPartitionTableSql = join(sqlDir, "load_partition_table.sql");

export type HereRealtimeTrafficDownloaderParams = {
  pg_env: PGEnv;
};

export type HereRealtimeTrafficDownloadTimeObj = {
  year: string;
  month: string;
  day: string;
  hour: string;
  minute: string;
  second: string;
};

export const zpad = (d: string | number, n: number) =>
  `${"0".repeat(n)}${d}`.slice(-n);

const getPsqlCredentials = memoizeOne((pgEnv: PGEnv) => {
  const configPath = getPostgresConfigurationFilePath(pgEnv);
  const configContents = readFileSync(configPath);

  return dotenv.parse(configContents);
});

const soleValidConstuctorKey = Symbol();

// TODO: params = pgEnv, hereRealtimeTrafficJsonGzipPath
export class HereRealtimeTrafficDatabaseLoader {
  static createHereRealtimeTrafficCsvStreamChain =
    createHereRealtimeTrafficCsvStreamChain;

  private static partitionTablesSchema = "here_realtime_traffic_partitions";

  private static validFileNameRE =
    /^here-realtime-traffic\.\d{8}T\d{6}.json.gz$/;

  private static fileNameParserRE =
    /^here-realtime-traffic\.(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2}).json.gz$/;

  private static validPartitionTableSuffix =
    /^y\d{4}m\d{2}w\d{1}d\d{2}h\d{2}m\d{2}$/;

  private static isValidFileName(hereRealtimeTrafficJsonGzip: string) {
    return HereRealtimeTrafficDatabaseLoader.validFileNameRE.test(
      hereRealtimeTrafficJsonGzip
    );
  }

  static parseHereRealtimeTrafficFileName = memoizeOne(
    (
      hereRealtimeTrafficJsonGzipPath: string
    ): HereRealtimeTrafficDownloadTimeObj => {
      const f = basename(hereRealtimeTrafficJsonGzipPath);

      if (!HereRealtimeTrafficDatabaseLoader.isValidFileName(f)) {
        throw new Error(`Invalid hereRealtimeTrafficJsonGzip file name: ${f}`);
      }

      const [, year, month, day, hour, minute, second] = f.match(
        HereRealtimeTrafficDatabaseLoader.fileNameParserRE
      );

      return {
        year,
        month,
        day,
        hour,
        minute,
        second,
      };
    }
  );

  static getHereRealtimeTrafficFileTimestamp(
    hereRealtimeTrafficJsonGzipPath: string
  ) {
    const partitionTimeObj =
      HereRealtimeTrafficDatabaseLoader.parseHereRealtimeTrafficFileName(
        hereRealtimeTrafficJsonGzipPath
      );

    const { year, month, day, hour, minute } = partitionTimeObj;

    const downloadTimestamp = new Date(
      `${year}-${month}-${day} ${hour}:${minute}:00`
    );

    return downloadTimestamp;
  }

  static getPartitionTableSuffix({
    year,
    month,
    day,
    hour,
    minute,
  }: HereRealtimeTrafficDownloadTimeObj): string {
    const yyyy = zpad(year, 4);
    const mm = zpad(month, 2);
    const dd = zpad(day, 2);
    const hh = zpad(hour, 2);
    const mn = zpad(minute, 2);

    const w = Math.max(0, Math.floor((+day - 1) / 7)) + 1;

    const partitionTableSuffix = `y${yyyy}m${mm}w${w}d${dd}h${hh}m${mn}`;

    // Need to verify or else we might make a mess in the database.
    if (
      !HereRealtimeTrafficDatabaseLoader.validPartitionTableSuffix.test(
        partitionTableSuffix
      )
    ) {
      throw new Error(
        `Invalid Here Realtime Traffic partition table suffix: ${partitionTableSuffix}`
      );
    }

    return partitionTableSuffix;
  }

  static getPartitionTableName(
    partitionTimeObj: HereRealtimeTrafficDownloadTimeObj
  ) {
    const partitionTableSuffix =
      HereRealtimeTrafficDatabaseLoader.getPartitionTableSuffix(
        partitionTimeObj
      );

    return `here_realtime_traffic_${partitionTableSuffix}`;
  }

  static getPartitionTableFullName(
    partitionTimeObj: HereRealtimeTrafficDownloadTimeObj
  ) {
    const partitionTableName =
      HereRealtimeTrafficDatabaseLoader.getPartitionTableName(partitionTimeObj);

    return `${HereRealtimeTrafficDatabaseLoader.partitionTablesSchema}.${partitionTableName}`;
  }

  static getPartitionPostgresTimestampExtent({
    year,
    month,
    day,
    hour,
    minute,
  }: HereRealtimeTrafficDownloadTimeObj): { start: string; end: string } {
    const start = `${year}${month}${day}T${hour}${minute}00`;
    const end = `${start}.1`;

    return { start, end };
  }

  private hereRealtimeTrafficDataFileQueue: string[];

  private loadingQueuedDataFiles: boolean;

  private loadStatusEventEmitter: EventEmitter;

  constructor(private readonly pgEnv: PGEnv, constructorKey: Symbol) {
    if (constructorKey !== soleValidConstuctorKey) {
      throw new Error(
        "HereRealtimeTrafficDatabaseLoaders must be created using the HereRealtimeTrafficDatabaseLoaderFactory."
      );
    }

    this.hereRealtimeTrafficDataFileQueue = [];
    this.loadingQueuedDataFiles = false;
    this.loadStatusEventEmitter = new EventEmitter();
    this.loadStatusEventEmitter.setMaxListeners(Infinity);
  }

  initializeDatabase() {
    const creds = getPsqlCredentials(this.pgEnv);

    execSync(
      `
      psql \
        -q \
        -f create_root_tables.sql \
        -f create_here_timestamp_handler_functions.sql \
        -f create_admin_views.sql \
        -f create_concatenate_here_realtime_partitions_proc.sql \
        -f create_concatenate_here_npmrds_schema_partitions_proc.sql \
        -f create_update_here_npmrds_schema_tables_proc.sql
      `,
      {
        cwd: join(__dirname, "../../../../sql/here_realtime_traffic"),
        env: {
          ...process.env,
          ...creds,
          PGOPTIONS: "--client_min_messages=error",
        },
        stdio: ["ignore", "inherit", "inherit"],
      }
    );
  }

  private async load(hereRealtimeTrafficJsonGzipPath: string) {
    const partitionTimeObj =
      HereRealtimeTrafficDatabaseLoader.parseHereRealtimeTrafficFileName(
        hereRealtimeTrafficJsonGzipPath
      );

    const partitionTableSuffix =
      HereRealtimeTrafficDatabaseLoader.getPartitionTableSuffix(
        partitionTimeObj
      );

    const { start, end } =
      HereRealtimeTrafficDatabaseLoader.getPartitionPostgresTimestampExtent(
        partitionTimeObj
      );

    const tableCols = hereRealtimeTrafficDatabaseTableColumns.join();

    const creds = getPsqlCredentials(this.pgEnv);

    const streamChain =
      HereRealtimeTrafficDatabaseLoader.createHereRealtimeTrafficCsvStreamChain(
        hereRealtimeTrafficJsonGzipPath
      );

    // TODO: Make sure load doesn't rollback if consolidate procedure fails.
    await new Promise((resolve, reject) => {
      const cproc = spawn(
        "psql",
        [
          "-q",
          "-v",
          "ON_ERROR_STOP=1",
          "-v",
          `PARTITION_TABLE_SUFFIX=${partitionTableSuffix}`,
          "-v",
          `TIME_RANGE_START=${start}`,
          "-v",
          `TIME_RANGE_END=${end}`,
          "-v",
          `TABLE_COLS=${tableCols}`,
          "-f",
          loadPartitionTableSql,
        ],
        {
          env: {
            ...process.env,
            ...creds,
            PGOPTIONS: "--client_min_messages=error",
          },
          stdio: ["pipe", "inherit", "pipe"],
        }
      );

      // collect STDERR for potential Error message.
      let stdoutMessages = `Loading ${basename(
        hereRealtimeTrafficJsonGzipPath
      )}:\n`;

      cproc.on("close", (code) => {
        if (code !== 0) {
          const errMsg = stdoutMessages || `psql exited with code ${code}`;
          return reject(new Error(errMsg));
        }

        resolve(null);
      });

      pipeline(
        // @ts-ignore
        [
          // @ts-ignore
          ...streamChain,
          // @ts-ignore
          cproc.stdin,
        ],
        (err) => {
          // NOTE: Resolving or rejecting in here may cause deadlocks in Postgres
          //       That's why we resolve in the psql process' "close" event listener.
          if (err) {
            // console.error(err);
            // Error in the CSV stream. Kill the child process.
            cproc.kill("SIGINT");
          }
        }
      );

      pipeline(
        cproc.stderr,
        through((chunk, _$, cb) => {
          stdoutMessages = `${stdoutMessages}${chunk}`;
          cb();
        }),
        (err) => {
          if (err) {
            console.error(err);
          }
        }
      );
    });

    return HereRealtimeTrafficDatabaseLoader.getPartitionTableFullName(
      partitionTimeObj
    );
  }

  private async loadQueuedDataFiles() {
    // Loading MUST be serial. This prevents concurrency.
    if (this.loadingQueuedDataFiles) {
      return;
    }

    this.loadingQueuedDataFiles = true;

    while (this.hereRealtimeTrafficDataFileQueue.length) {
      // Sort because priority queue based on time precedence.
      const [hereRealtimeTrafficJsonGzipPath] =
        this.hereRealtimeTrafficDataFileQueue.sort();

      try {
        const partitionTableFullName = await this.load(
          hereRealtimeTrafficJsonGzipPath
        );

        this.loadStatusEventEmitter.emit("success", {
          hereRealtimeTrafficJsonGzipPath,
          partitionTableFullName,
        });
      } catch (error) {
        this.loadStatusEventEmitter.emit("failure", {
          hereRealtimeTrafficJsonGzipPath,
          error,
        });
      }

      // Remove the loaded file from the queue AFTER loading so code awaiting file[s] load
      //   will know when loading that file[s] is done.
      //
      //   NOTE: While awaiting load, this.hereRealtimeTrafficDataFileQueue may have changed.
      //         Cannot assume still the first element of the array.
      const index = this.hereRealtimeTrafficDataFileQueue.findIndex(
        (f) => f === hereRealtimeTrafficJsonGzipPath
      );

      this.hereRealtimeTrafficDataFileQueue.splice(index, 1);
    }

    // this.hereRealtimeTrafficDataFileQueue is empty
    this.loadingQueuedDataFiles = false;
  }

  private addHereRealtimeTrafficDataFileToLoaderQueue(
    hereRealtimeTrafficJsonGzipPath: string
  ) {
    if (
      !this.hereRealtimeTrafficDataFileQueue.includes(
        hereRealtimeTrafficJsonGzipPath
      )
    ) {
      this.hereRealtimeTrafficDataFileQueue.push(
        hereRealtimeTrafficJsonGzipPath
      );
    }

    process.nextTick(this.loadQueuedDataFiles.bind(this));
  }

  async bulkLoadDataFiles(
    hereRealtimeTrafficJsonGzipPaths: string[]
  ): Promise<Array<string | Error>> {
    const files = _.uniq(hereRealtimeTrafficJsonGzipPaths).sort();

    const awaiting = new Set(files);

    const partitionTableFullNamesByFilePath = {};
    const loadErrorsByFilePath = {};

    const successHandler = ({
      hereRealtimeTrafficJsonGzipPath,
      partitionTableFullName,
    }) => {
      awaiting.delete(hereRealtimeTrafficJsonGzipPath);

      // console.error("SUCCESS:", basename(hereRealtimeTrafficJsonGzipPath));
      // console.error();

      partitionTableFullNamesByFilePath[hereRealtimeTrafficJsonGzipPath] =
        partitionTableFullName;
    };

    const failureHandler = ({ hereRealtimeTrafficJsonGzipPath, error }) => {
      awaiting.delete(hereRealtimeTrafficJsonGzipPath);

      // console.error("FAIL:", basename(hereRealtimeTrafficJsonGzipPath));
      // console.error(error.message);
      // console.error();

      loadErrorsByFilePath[hereRealtimeTrafficJsonGzipPath] = error;
    };

    this.loadStatusEventEmitter.on("success", successHandler);
    this.loadStatusEventEmitter.on("failure", failureHandler);

    files.forEach((f) => this.addHereRealtimeTrafficDataFileToLoaderQueue(f));

    return new Promise((resolve) => {
      const x = setInterval(() => {
        if (awaiting.size === 0) {
          clearInterval(x);

          this.loadStatusEventEmitter.off("success", successHandler);
          this.loadStatusEventEmitter.off("failure", failureHandler);

          const results = hereRealtimeTrafficJsonGzipPaths.map(
            (f) =>
              partitionTableFullNamesByFilePath[f] || loadErrorsByFilePath[f]
          );

          return resolve(results);
        }
      }, 0);
    });
  }

  async loadHereRealtimeTrafficDataFile(
    hereRealtimeTrafficJsonGzipPath: string
  ): Promise<string> {
    const [result] = await this.bulkLoadDataFiles([
      hereRealtimeTrafficJsonGzipPath,
    ]);

    if (result instanceof Error) {
      throw result;
    }

    return result;
  }
}

// @ts-ignore
const loadersByPgEnv: Record<PGEnv, HereRealtimeTrafficDatabaseLoader> = {};

// Loaders MUST be singletons to guarantee loading is done serially.
//    The below factory guarantees a single loader per database within a process.
//      TODO: add a PID file to be xtra safe and guarantee single loader per machine.
//   Requiring the factory create instances causes a bit of an inconvenience with static members.
//     To access a static member bar on an instance of class Foo: foo.constructor.bar
//   See: https://stackoverflow.com/questions/19470559/how-to-access-static-member-on-instance
export default class HereRealtimeTrafficDatabaseLoaderFactory {
  static makeHereRealtimeTrafficDatabaseLoader(
    pgEnv: PGEnv
  ): HereRealtimeTrafficDatabaseLoader {
    if (loadersByPgEnv[pgEnv]) {
      return loadersByPgEnv[pgEnv];
    }

    loadersByPgEnv[pgEnv] = new HereRealtimeTrafficDatabaseLoader(
      pgEnv,
      soleValidConstuctorKey
    );

    return loadersByPgEnv[pgEnv];
  }
}
