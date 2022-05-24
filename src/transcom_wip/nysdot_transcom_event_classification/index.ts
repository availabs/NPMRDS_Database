import { createReadStream } from "fs";
import { pipeline } from "stream";
import { promisify } from "util";

import {
  parse as csvParse,
  format as csvFormat,
  CsvFormatterStream,
} from "fast-csv";

import _ from "lodash";
import pgFormat from "pg-format";
import { from as copyFrom } from "pg-copy-streams";

import { Client } from "pg";

import { NysdotTranscomEventClassification } from "./index.d";

import { csvColToDbColMapper, dbCols } from "./data_schema";

const pipelineAsync = promisify(pipeline);

export async function* makeNysdotTranscomEventClassificationsIterator(
  csvFilePath: string
): AsyncGenerator<NysdotTranscomEventClassification> {
  const iter = pipeline(
    createReadStream(csvFilePath),
    csvParse({
      headers: csvColToDbColMapper,
      ignoreEmpty: true,
      trim: true,
      discardUnmappedColumns: true,
    }),
    (err) => {
      if (err) {
        console.error(err);
      }
    }
  );

  for await (const row of iter) {
    if (!row.event_type) {
      // console.error(
      // "Warning: skipping row with null event_type",
      // JSON.stringify(row)
      // );
      continue;
    }

    const d = <NysdotTranscomEventClassification>_(row)
      .omitBy((_v, k) => /^_unsupported_/.test(k))
      .mapValues((v) => (v === "" ? null : v))
      .value();

    d.event_type = d.event_type.toLowerCase();

    yield d;
  }
}

export function nysdotTranscomEventClassifcationsToCsvStream(
  nysdotTranscomEventClassificationsIterator: AsyncGenerator<NysdotTranscomEventClassification>
): CsvFormatterStream<NysdotTranscomEventClassification, any> {
  const csvStream = csvFormat({
    headers: dbCols,
    quoteHeaders: false,
    quote: '"',
  });

  process.nextTick(async () => {
    for await (const row of nysdotTranscomEventClassificationsIterator) {
      const ready = csvStream.write(row);

      if (!ready) {
        await new Promise((resolve) => csvStream.once("drain", resolve));
        console.error("drain event");
      }
    }

    csvStream.end();
  });

  return csvStream;
}

export async function loadCsvIntoDb(
  csvFilePath: string,
  schemaName: string,
  tableName: string,
  db: Client
) {
  // NOTE: using the transcomEventsDatabaseTableColumns array
  //       keeps column order consistent with transcomEventsCsvStream
  const colIdentifiers = dbCols.slice().fill("%I").join();

  const clearSql = pgFormat("TRUNCATE %I.%I;", schemaName, tableName);

  await db.query(clearSql);

  const loadSql = pgFormat(
    `COPY %I.%I (${colIdentifiers}) FROM STDIN WITH CSV HEADER ;`,
    schemaName,
    tableName,
    ...dbCols
  );

  console.log(loadSql);

  const pgCopyStream = db.query(copyFrom(loadSql));

  const iter = makeNysdotTranscomEventClassificationsIterator(csvFilePath);
  const csvStream = nysdotTranscomEventClassifcationsToCsvStream(iter);

  await pipelineAsync(csvStream, pgCopyStream);
}
