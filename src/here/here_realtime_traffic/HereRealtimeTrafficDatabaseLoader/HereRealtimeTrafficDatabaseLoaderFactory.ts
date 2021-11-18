// FIXME: Should verify that metadata timestamp agrees with gzip name.

import { spawn, execSync } from "child_process";
import EventEmitter from "events";
import { readFileSync } from "fs";
import { pipeline } from "stream";
import { join, basename } from "path";
import memoizeOne from "memoize-one";
import through from "through2";

import dotenv from "dotenv";
import _ from "lodash";

import logger from "../utils/logger";

import { getPostgresConfigurationFilePath } from "../../../../make_targets/utils";

import createHereRealtimeTrafficCsvStreamChain from "./utils/createHereRealtimeTrafficCsvStreamChain";

import hereRealtimeTrafficDatabaseTableColumns from "./utils/hereRealtimeTrafficDatabaseTableColumns";

import {
  HereRealtimeTrafficJsonGzipPath,
  HereRealtimeTrafficRequestTimestamp,
  HereRealtimeTrafficDownloaderResponseMetadata,
  HereRealtimeTrafficDownloadTimeObj,
  PGEnv,
} from "../types";

import HereRealtimeTrafficDownloader from "../HereRealtimeTrafficDownloader";

const sqlDir = join(__dirname, "../../../../sql/here_realtime_traffic");

const loadPartitionTableSql = join(sqlDir, "load_partition_table.sql");

export type HereRealtimeTrafficDownloaderParams = {
  pg_env: PGEnv;
};

export const zpad = (d: string | number, n: number) =>
  `${"0".repeat(n)}${d}`.slice(-n);

const getPsqlCredentials = memoizeOne((pgEnv: PGEnv) => {
  const configPath = getPostgresConfigurationFilePath(pgEnv);
  const configContents = readFileSync(configPath);

  return dotenv.parse(configContents);
});

// Used to enforce singleton loader.
const soleValidConstuctorKey = Symbol();

// TODO: params = pgEnv, hereRealtimeTrafficJsonGzipPath
export class HereRealtimeTrafficDatabaseLoader {
  static createHereRealtimeTrafficCsvStreamChain =
    createHereRealtimeTrafficCsvStreamChain;

  private static partitionTablesSchema = "here_realtime_traffic_partitions";

  private static validPartitionTableSuffix =
    /^y\d{4}m\d{2}w\d{1}d\d{2}h\d{2}m\d{2}$/;

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

  // FIXME: DB loader SQL should handle the end timestamp itself.
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

  private hereRealtimeTrafficDownloaderResponseMetadataQueue: HereRealtimeTrafficDownloaderResponseMetadata[];

  private loadingQueuedDataFiles: boolean;

  private loadStatusEventEmitter: EventEmitter;
  private _latestHereRealtimeTrafficTimestamp: Date | null;
  private _databaseInitialized: boolean;

  constructor(private readonly pgEnv: PGEnv, constructorKey: Symbol) {
    if (constructorKey !== soleValidConstuctorKey) {
      throw new Error(
        "HereRealtimeTrafficDatabaseLoaders must be created using the HereRealtimeTrafficDatabaseLoaderFactory."
      );
    }

    this.hereRealtimeTrafficDownloaderResponseMetadataQueue = [];
    this.loadingQueuedDataFiles = false;
    this.loadStatusEventEmitter = new EventEmitter();
    this.loadStatusEventEmitter.setMaxListeners(Infinity);
    this._databaseInitialized = false;
  }

  initializeDatabase() {
    if (this._databaseInitialized) {
      return;
    }

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

    this._databaseInitialized = true;
  }

  get latestHereRealtimeTrafficTimestamp() {
    if (this._latestHereRealtimeTrafficTimestamp) {
      return this._latestHereRealtimeTrafficTimestamp;
    }

    this.initializeDatabase();

    const creds = getPsqlCredentials(this.pgEnv);

    const tstampStr = execSync(
      `
      psql \
        -qAt \
        -c '
          SELECT
              timestamp
            FROM public.here_realtime_traffic_current
            LIMIT 1
          ;
        '
      `,
      {
        encoding: "utf8",
        env: {
          ...process.env,
          ...creds,
          PGOPTIONS: "--client_min_messages=error",
        },
      }
    );

    this._latestHereRealtimeTrafficTimestamp = tstampStr.trim().length
      ? new Date(tstampStr)
      : null;

    return this._latestHereRealtimeTrafficTimestamp;
  }

  set latestHereRealtimeTrafficTimestamp(tstamp: Date) {
    if (tstamp > this._latestHereRealtimeTrafficTimestamp) {
      this._latestHereRealtimeTrafficTimestamp = tstamp;
    }
  }

  private async load(hereRealtimeTrafficJsonGzipPath: string) {
    const partitionTimeObj =
      HereRealtimeTrafficDownloader.parseHereRealtimeTrafficFileName(
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

  private async updateHereNpmrdsSchemaTables(
    reqTstamp: HereRealtimeTrafficRequestTimestamp
  ) {
    const reqTstampStr = reqTstamp.toLocaleString();

    const creds = getPsqlCredentials(this.pgEnv);

    // TODO: Make sure load doesn't rollback if consolidate procedure fails.
    await new Promise((resolve, reject) => {
      const cproc = spawn(
        "psql",
        [
          "-q",
          "-v",
          "ON_ERROR_STOP=1",
          "-c",
          `CALL here_npmrds_schema_partitions.update_here_npmrds_schema_tables_proc(
            '${reqTstampStr}'::TIMESTAMP
          )`,
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
      let stdoutMessages = `Updating here_npmrds_schema_partitions for timestamp ${reqTstampStr}:\n`;

      cproc.on("close", (code) => {
        if (code !== 0) {
          const errMsg = stdoutMessages || `psql exited with code ${code}`;
          return reject(new Error(errMsg));
        }

        resolve(null);
      });
    });
  }

  private async loadQueuedData() {
    // Loading MUST be serial. This prevents concurrency.
    if (this.loadingQueuedDataFiles) {
      return;
    }

    this.loadingQueuedDataFiles = true;

    while (this.hereRealtimeTrafficDownloaderResponseMetadataQueue.length) {
      // Sort because priority queue based on time precedence.
      const [hereRealtimeTrafficDownloaderResponseMetadata] = _(
        this.hereRealtimeTrafficDownloaderResponseMetadataQueue
      )
        .uniqWith(_.isEqual)
        .sortBy("hereRealtimeTrafficRequestTimestamp")
        .value();

      const {
        hereRealtimeTrafficRequestTimestamp,
        hereRealtimeTrafficJsonGzipPath,
      } = hereRealtimeTrafficDownloaderResponseMetadata;

      try {
        // console.log(
        // "hereRealtimeTrafficRequestTimestamp:",
        // hereRealtimeTrafficRequestTimestamp
        // );
        // console.log(
        // "latestHereRealtimeTrafficTimestamp:",
        // this.latestHereRealtimeTrafficTimestamp
        // );

        const latestTstamp = this.latestHereRealtimeTrafficTimestamp;

        // console.log(latestTstamp);
        // process.exit();

        if (
          latestTstamp !== null &&
          hereRealtimeTrafficRequestTimestamp <= latestTstamp
        ) {
          throw new Error(`Error:
            hereRealtimeTrafficRequestTimestamp ${hereRealtimeTrafficRequestTimestamp}
            does not strictly follow the
            latestHereRealtimeTrafficTimestamp ${latestTstamp}
          `);
        }

        if (hereRealtimeTrafficJsonGzipPath) {
          const partitionTableFullName = await this.load(
            hereRealtimeTrafficJsonGzipPath
          );

          const partitionTableSuffix = partitionTableFullName.slice(-19);

          logger.log(
            "loaded here_realtime_traffic table",
            partitionTableSuffix,
            "\n"
          );
        } else {
          // No file path. API request failed. Just have timestamp to use
          //   in update_here_npmrds_schema_tables_proc call.
          await this.updateHereNpmrdsSchemaTables(
            hereRealtimeTrafficRequestTimestamp
          );

          logger.log(
            "No hereRealtimeTrafficJsonGzip file. Updated here_npmrds_schema for",
            hereRealtimeTrafficRequestTimestamp,
            "\n"
          );
        }

        this.loadStatusEventEmitter.emit("loaded", {
          hereRealtimeTrafficDownloaderResponseMetadata,
          error: null,
        });
      } catch (error) {
        this.loadStatusEventEmitter.emit("loaded", {
          hereRealtimeTrafficDownloaderResponseMetadata,
          error,
        });
      }

      // Remove the loaded file from the queue AFTER loading so code awaiting file[s] load
      //   will know when loading that file[s] is done.
      //
      //   NOTE: While awaiting load, this.hereRealtimeTrafficDownloaderResponseMetadataQueue may have changed.
      //         Cannot assume still the first element of the array.
      const index =
        this.hereRealtimeTrafficDownloaderResponseMetadataQueue.findIndex(
          (m) => m === hereRealtimeTrafficDownloaderResponseMetadata
        );

      this.hereRealtimeTrafficDownloaderResponseMetadataQueue.splice(index, 1);
    }

    // The hereRealtimeTrafficDownloaderResponseMetadataQueue is empty
    // NOTE: The while loop check happens synchronously.
    //       If a call to loadQueuedData returned because loadingQueuedDataFiles was true,
    //         that queued metadata would be in the queue despite the early return.
    //         Therefore, the above loop and the loadingQueuedDataFiles control variable are async-safe.
    this.loadingQueuedDataFiles = false;
  }

  // TODO: Instead of returning a Promise, return an AsyncGenerator so caller can monitor progress.
  async bulkLoadHereRealtimeData(
    batchMetadata: HereRealtimeTrafficDownloaderResponseMetadata[]
  ): Promise<
    Array<{
      hereRealtimeTrafficDownloaderResponseMetadata: HereRealtimeTrafficDownloaderResponseMetadata;
      dbLoadError: Error | null;
    }>
  > {
    this.initializeDatabase();

    // If equivalent metadata already exists in the queue, use the existing object/reference.
    const queueIntersection = _.intersectionWith(
      this.hereRealtimeTrafficDownloaderResponseMetadataQueue,
      batchMetadata,
      _.isEqual
    );
    //  Metadata without equivalent entries in the queue,
    //    cloned so caller cannot mutate.
    const queueDifference = _.cloneDeep(
      _.differenceWith(
        batchMetadata,
        this.hereRealtimeTrafficDownloaderResponseMetadataQueue,
        _.isEqual
      )
    );

    const batch = _.sortBy(
      [...queueIntersection, ...queueDifference],
      "hereRealtimeTrafficRequestTimestamp"
    );

    // NOTE: Awaiting responseMetadata object references MUST be same as what is in loading queue.
    const awaiting = new Set(batch);

    const loadResultsByMetadata: Map<
      HereRealtimeTrafficDownloaderResponseMetadata,
      Error | null
    > = new Map();

    const loadedEventHandler = ({
      hereRealtimeTrafficDownloaderResponseMetadata,
      error,
    }: {
      hereRealtimeTrafficDownloaderResponseMetadata: HereRealtimeTrafficDownloaderResponseMetadata;
      error: Error | null;
    }) => {
      if (error) {
        logger.error(error.message);
      }

      if (awaiting.has(hereRealtimeTrafficDownloaderResponseMetadata)) {
        awaiting.delete(hereRealtimeTrafficDownloaderResponseMetadata);

        this.latestHereRealtimeTrafficTimestamp =
          hereRealtimeTrafficDownloaderResponseMetadata.hereRealtimeTrafficRequestTimestamp;

        loadResultsByMetadata.set(
          hereRealtimeTrafficDownloaderResponseMetadata,
          error
        );
      }
    };

    this.loadStatusEventEmitter.on("loaded", loadedEventHandler);

    batch.forEach((metadata) =>
      this.hereRealtimeTrafficDownloaderResponseMetadataQueue.push(metadata)
    );

    process.nextTick(this.loadQueuedData.bind(this));

    return new Promise((resolve) => {
      const x = setInterval(() => {
        if (awaiting.size === 0) {
          clearInterval(x);

          this.loadStatusEventEmitter.off("loaded", loadedEventHandler);

          const results = _.sortBy(
            [...loadResultsByMetadata.entries()].map(([metadata, error]) => ({
              hereRealtimeTrafficDownloaderResponseMetadata:
                _.cloneDeep(metadata),
              dbLoadError: error,
            })),
            "hereRealtimeTrafficDownloaderResponseMetadata.hereRealtimeTrafficRequestTimestamp"
          );

          return resolve(results);
        }
      }, 0);
    });
  }

  async loadHereRealtimeTrafficData(
    metadata: HereRealtimeTrafficDownloaderResponseMetadata
  ): Promise<HereRealtimeTrafficDownloaderResponseMetadata> {
    const [{ hereRealtimeTrafficDownloaderResponseMetadata, dbLoadError }] =
      await this.bulkLoadHereRealtimeData([metadata]);

    if (dbLoadError !== null) {
      throw dbLoadError;
    }

    return hereRealtimeTrafficDownloaderResponseMetadata;
  }

  async bulkLoadDataFiles(
    paths: HereRealtimeTrafficJsonGzipPath[],
    filter: boolean = true
  ) {
    const metadata =
      HereRealtimeTrafficDownloader.hereRealtimeTrafficJsonGzipPathsToHereRealtimeTrafficRequestMetadata(
        paths
      );

    const latestTstamp = this.latestHereRealtimeTrafficTimestamp;

    const batchMetadata = filter
      ? metadata.filter(
          (m) => m.hereRealtimeTrafficRequestTimestamp > latestTstamp
        )
      : metadata;

    return await this.bulkLoadHereRealtimeData(batchMetadata);
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
