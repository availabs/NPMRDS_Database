import { execSync } from "child_process";
import { join } from "path";

import dotenv from "dotenv";

import Client from "pg-native";

import { getPostgresConfigurationFilePath } from "../../../make_targets/utils";

const sqlDir = join(__dirname, "../../../sql/npmrds_monthly_avg_tt_by_hour");

export default class NpmrdsMonthlyAvgTravelTimesLoader {
  private client: Client;

  constructor(private pg_env: "development" | "production" = "development") {
    const configPath = getPostgresConfigurationFilePath(this.pg_env);

    dotenv.config({ path: configPath });

    const { PGDATABASE, PGHOST, PGPORT } = process.env;
    console.error(`${PGDATABASE} at ${PGHOST}:${PGPORT}`);

    this.client = new Client();
  }

  private get rootTableExists(): boolean {
    const { exists } = this.client.querySync(`
      SELECT EXISTS (
        SELECT
            1
          FROM information_schema.tables t
          WHERE (
            ( t.table_schema = 'public' )
            AND
            ( t.table_name = 'npmrds_monthly_avg_tt_by_hour' )
          )
      ) AS exists
    `);

    return exists;
  }

  private createRootTable() {
    if (!this.rootTableExists) {
      const createRootTableSqlPath = join(sqlDir, "create_root_table.sql");

      execSync(`
        psql \
          -v ON_ERROR_STOP=1 \
          -f ${createRootTableSqlPath}
      `);
    }
  }

  private get missingYearMonthPartitionTables(): {
    year: number;
    month: number;
  }[] {
    const missingYearMonths = this.client.querySync(`
        SELECT
            SUBSTRING( t.table_name FROM 9 FOR 4 )::INTEGER AS year,
            SUBSTRING( t.table_name FROM 14 FOR 2 )::INTEGER AS month
          FROM information_schema.tables t
          WHERE (
            ( t.table_schema <> 'public' )
            AND
            ( t.table_name ~ '^npmrds_y\\d{4}m\\d{2}$'::text )
          )

        EXCEPT

        SELECT
            SUBSTRING( t.table_name FROM 32 FOR 4 )::INTEGER AS year,
            SUBSTRING( t.table_name FROM 37 FOR 2 )::INTEGER AS month
          FROM information_schema.tables t
          WHERE (
            ( t.table_schema = 'npmrds_monthly_avg_tt_by_hour_partitions' )
            AND
            ( t.table_name ~ '^npmrds_monthly_avg_tt_by_hour_y\\d{4}m\\d{2}$'::text )
          )

        ORDER BY year, month
      `);

    return missingYearMonths;
  }

  private createMissingYearMonthPartitionTables() {
    const createMonthPartitionSqlPath = join(
      sqlDir,
      "create_month_partition_table.sql"
    );

    for (const { year, month } of this.missingYearMonthPartitionTables) {
      const mm = `0${month}`.slice(-2);

      execSync(`
        psql \
          -v ON_ERROR_STOP=1 \
          -v YEAR=${year} \
          -v MONTH=${mm} \
          -v NEXT_YEAR=${year + 1} \
          -v NEXT_MONTH=${month + 1} \
          -f ${createMonthPartitionSqlPath}
      `);
    }
  }

  private get missingStateYearMonthPartitionTables(): {
    state: string;
    year: number;
    month: number;
  }[] {
    const missingYearMonths = this.client.querySync(`
        SELECT
            t.table_schema AS state,
            SUBSTRING( t.table_name FROM 9 FOR 4 )::INTEGER AS year,
            SUBSTRING( t.table_name FROM 14 FOR 2 )::INTEGER AS month
          FROM information_schema.tables t
          WHERE (
            ( t.table_schema <> 'public' )
            AND
            ( t.table_name ~ '^npmrds_y\\d{4}m\\d{2}$'::text )
          )

        EXCEPT

        SELECT
            t.table_schema AS state,
            SUBSTRING( t.table_name FROM 32 FOR 4 )::INTEGER AS year,
            SUBSTRING( t.table_name FROM 37 FOR 2 )::INTEGER AS month
          FROM information_schema.tables t
          WHERE (
            ( t.table_schema <> 'npmrds_monthly_avg_tt_by_hour_partitions' )
            AND
            ( t.table_name ~ '^npmrds_monthly_avg_tt_by_hour_y\\d{4}m\\d{2}$'::text )
          )

        ORDER BY state, year, month
      `);

    return missingYearMonths;
  }

  private createMissingStateYearMonthPartitionTables() {
    const createStateMonthPartitionSqlPath = join(
      sqlDir,
      "create_state_month_partition_table.sql"
    );

    const missingTables = this.missingStateYearMonthPartitionTables;

    for (const { state, year, month } of missingTables) {
      const mm = `0${month}`.slice(-2);

      execSync(`
        psql \
          -v ON_ERROR_STOP=1 \
          -v STATE=${state} \
          -v YEAR=${year} \
          -v MONTH=${mm} \
          -f ${createStateMonthPartitionSqlPath}
      `);
    }
  }

  private get emptyStateYearMonthPartitionTables(): {
    state: string;
    year: number;
    month: number;
  }[] {
    const existingTables = this.client.querySync(`
      SELECT
          t.table_schema AS state,
          SUBSTRING( t.table_name FROM 32 FOR 4 )::INTEGER AS year,
          SUBSTRING( t.table_name FROM 37 FOR 2 )::INTEGER AS month
        FROM information_schema.tables t
        WHERE (
          ( t.table_schema <> 'npmrds_monthly_avg_tt_by_hour_partitions' )
          AND
          ( t.table_name ~ '^npmrds_monthly_avg_tt_by_hour_y\\d{4}m\\d{2}$'::text )
        )
        ORDER BY 1,2,3
    `);

    const emptyTables = existingTables.filter(({ state, year, month }) => {
      const mm = `0${month}`.slice(-2);

      const not_exists = this.client.querySync(`
        SELECT NOT EXISTS (
          SELECT
              1
            FROM "${state}".npmrds_monthly_avg_tt_by_hour_y${year}m${mm}
        ) AS not_exists
      `);

      return not_exists;
    });

    return emptyTables;
  }

  private loadEmptyStateYearMonthPartitionTables() {
    const emptyTables = this.emptyStateYearMonthPartitionTables;
    for (const { state, year, month } of emptyTables) {
      const mm = `0${month}`.slice(-2);

      this.client.querySync(`
        BEGIN ;

        INSERT INTO "${state}".npmrds_monthly_avg_tt_by_hour_y${year}m${mm} (
          tmc,
          hour,
          avg_tt
        )
          SELECT
              tmc,
              (epoch / 12)::INTEGER AS hour,
              AVG(travel_time_all_vehicles)::REAL AS avg_tt
            FROM "${state}".npmrds_y${year}m${mm}
            GROUP BY 1, 2
        ;

        CLUSTER "${state}".npmrds_monthly_avg_tt_by_hour_y${year}m${mm} ;

        COMMIT ;

        ANALYZE "${state}".npmrds_monthly_avg_tt_by_hour_y${year}m${mm} ;
      `);
    }
  }

  test() {
    this.client.connectSync();

    console.log(
      JSON.stringify(
        {
          rootTableExists: this.rootTableExists,
          missingYearMonthPartitionTables: this.missingYearMonthPartitionTables,
          missingStateYearMonthPartitionTables:
            this.missingStateYearMonthPartitionTables,
        },
        null,
        4
      )
    );

    this.client.end();
  }

  run() {
    this.client.connectSync();
    this.createRootTable();
    this.createMissingYearMonthPartitionTables();
    this.createMissingStateYearMonthPartitionTables();
    this.loadEmptyStateYearMonthPartitionTables();
    this.client.end();
  }
}
