#!/usr/bin/env node

const split = require("split2");
const _ = require("lodash");

let objectsCount = 0;

let i = 0;

const SAMPLES_LEN = 10;

const decimalPointRE = /\./;

// NOTE: 0 and 1 handled by converting to JS number to allow
//       transitioning from BOOLEAN to pgNumericType
const booleanTextRE =
  /(^t$)|(^f$)|(^y$)|(^n$)|(^true$)|(^false$)|(^yes$)|(^no$)/i;

const pgTypes = {
  BOOLEAN: "BOOLEAN",
  SMALLINT: "SMALLINT",
  INT: "INTEGER",
  BIGINT: "BIGINT",
  REAL: "REAL",
  DOUBLE: "DOUBLE PRECISION",
  NUMERIC: "NUMERIC",
  DATE: "DATE",
  TIMESTAMP: "TIMESTAMP",
  TEXT: "TEXT",
};

const pgIntegerTypes = [pgTypes.SMALLINT, pgTypes.INT, pgTypes.BIGINT];
const pgDecimalTypes = [pgTypes.REAL, pgTypes.DOUBLE, pgTypes.NUMERIC];
const pgNumericTypes = [...pgIntegerTypes, ...pgDecimalTypes];
const pgDateTypes = [pgTypes.DATE, pgTypes.TIMESTAMP];

async function* makeIterFromStdin() {
  const iter = process.stdin.pipe(split());
  for await (const line of iter) {
    try {
      yield JSON.parse(line);
    } catch (err) {
      //
    }
  }
}

async function analyzeSchema(schemaAnalysis = [], objIter) {
  const keyIdxs = schemaAnalysis.reduce((acc, { key }, i) => {
    acc[key] = i;
    return acc;
  }, {});

  for await (const d of objIter) {
    try {
      ++objectsCount;

      const hadTextualBoolean = new Set();

      for (const k of Object.keys(d)) {
        keyIdxs[k] = Number.isFinite(keyIdxs[k]) ? keyIdxs[k] : i++;

        schemaAnalysis[keyIdxs[k]] = schemaAnalysis[keyIdxs[k]] || {
          key: k,
          col: _.snakeCase(k),
          summary: {
            null: 0,
            nonnull: 0,
            types: {},
            db_type: null,
          },
        };

        const { summary } = schemaAnalysis[keyIdxs[k]];

        let v = d[k];

        let t = v === null ? null : typeof v;

        if (t === "string") {
          v = v.trim();
          if (v === "") {
            t = null;
          }
        }

        pgTypeCheck: if (
          t !== null && // null tells us nothing
          v !== "" && // empty string tells us nothing
          summary.db_type !== pgTypes.TEXT // Once TEXT, always TEXT
        ) {
          // Hard to stay BOOLEAN
          pgBooleanTypeCheck: if (
            summary.db_type === null ||
            summary.db_type === pgTypes.BOOLEAN
          ) {
            if (t === "boolean") {
              summary.db_type = pgTypes.BOOLEAN;
              break pgTypeCheck;
            }
            // NOTE: We handle numeric values differently than strings
            //       to support transitioning from BOOLEAN to pgNumericType
            const n = +v;

            if (Number.isFinite(n)) {
              if (n === 0 || n === 1) {
                summary.db_type = pgTypes.BOOLEAN;
                break pgTypeCheck;
              }

              // v is a number out of BOOLEAN range [0,1]

              if (hadTextualBoolean.has(k)) {
                // Had non-pgDateType text, now numeric out of boolean range => TEXT
                summary.db_type = pgTypes.TEXT;
                break pgTypeCheck;
              }

              summary.db_type = pgTypes.SMALLINT;
              break pgBooleanTypeCheck;
              // falls through in pgTypeCheck. Will enter pgNumericTypeCheck below.
            }

            if (t === "string") {
              if (booleanTextRE.test(v.trim())) {
                hadTextualBoolean.add(k); // Can no longer be an pgIntegerType
                summary.db_type = pgTypes.BOOLEAN;
                break pgTypeCheck;
              } else if (hadTextualBoolean.has(k)) {
                // cannot be a pgDateTypes
                summary.db_type = pgTypes.TEXT;
                break pgTypeCheck;
              } else if (summary.db_type === null) {
                // could be pgDateType
                break pgBooleanTypeCheck;
                // falls through in pgTypeCheck
              }
            }

            summary.db_type = pgTypes.TEXT;
          }

          // Check if property maps to pgDateTypes
          pgDateTypeCheck: if (
            summary.db_type === null ||
            pgDateTypes.includes(summary.db_type)
          ) {
            if (Number.isFinite(+v)) {
              if (summary.db_type === null) {
                // May still be pgNumericType
                break pgDateTypeCheck;
              } else {
                // console.error(k, "!Number.isFinite", v);
                // pgDateTypes eliminated
                summary.db_type = pgTypes.TEXT;
                break pgTypeCheck;
              }
            }

            const date = new Date(v);
            const isValidDate = Number.isFinite(date.getTime());

            if (!isValidDate) {
              // console.error(k, "!isValidDate", v);
              summary.db_type = pgTypes.TEXT;
              break pgTypeCheck;
            }

            if (summary.db_type === null) {
              summary.db_type = pgTypes.DATE;
              // falls through
            }

            if (summary.db_type === pgTypes.DATE && /T|:/.test(v)) {
              summary.db_type = pgTypes.TIMESTAMP;
            }

            break pgTypeCheck;
          }

          // Check if pgNumericType
          //   See: https://www.postgresql.org/docs/11/datatype-numeric.html
          /* pgNumericTypeCheck : */ if (
            summary.db_type === null ||
            pgNumericTypes.includes(summary.db_type)
          ) {
            const n = +v;
            const s = `${v}`; // v = "1.0", `${v}` = "1.0"

            // NOTE: Assumes we already eliminated pgDateTypes above.
            if (!Number.isFinite(n)) {
              summary.db_type = pgTypes.TEXT;
              break pgTypeCheck;
            }

            // The value parses to a valid number.

            // NUMERIC is the sink for pgNumericTypes
            if (summary.db_type === pgTypes.NUMERIC) {
              break pgTypeCheck;
            }

            const containsDecimalPoint = decimalPointRE.test(s);

            // Once a pgDecimalType, cannot be a pgIntegerType
            if (containsDecimalPoint) {
              // First we convert current pgIntegerType to the corresponding pgDecimalType
              pgInt2Decimal: if (pgIntegerTypes.includes(summary.db_type)) {
                if (summary.db_type === pgTypes.SMALLINT) {
                  summary.db_type = pgTypes.REAL;
                  break pgInt2Decimal;
                  // falls through in if(containsDecimalPoint)
                }

                if (summary.db_type === pgTypes.INT) {
                  summary.db_type = pgTypes.DOUBLE;
                  break pgInt2Decimal;
                  // falls through in if(containsDecimalPoint)
                }

                if (summary.db_type === pgTypes.BIGINT) {
                  // We've reached the sink for pgNumericTypes
                  summary.db_type = pgTypes.NUMERIC;
                  break pgTypeCheck;
                }
              }

              if (summary.db_type === null) {
                summary.db_type = pgTypes.REAL;
                // falls through
              }

              // REAL supports 6 decimal digits of precision
              if (summary.db_type === pgTypes.REAL && s.length > 7) {
                summary.db_type = pgTypes.DOUBLE;
                // falls through
              }

              // DOUBLE PRECISION supports 15 decimal digits of precision
              if (summary.db_type === pgTypes.DOUBLE && s.length > 16) {
                summary.db_type = pgTypes.NUMERIC;
                // falls through
              }

              break pgTypeCheck;
            }

            // n does not contain a decimal point

            if (
              summary.db_type === pgTypes.REAL ||
              summary.db_type === pgTypes.DOUBLE
            ) {
              // We already assigned a pgDecimalType for this property.
              // Now we check if the current integer exceeds the pgDecimalType range.

              if (summary.db_type === pgTypes.REAL && s.length > 6) {
                summary.db_type = pgTypes.DOUBLE;
                // falls through
              }
              if (summary.db_type === pgTypes.DOUBLE && s.length > 15) {
                // upgrade DOUBLE to NUMERIC
                summary.db_type = pgTypes.NUMERIC;
                // falls through
              }

              break pgTypeCheck;
            }

            // We either have not
            if (summary.db_type === null) {
              summary.db_type = pgTypes.SMALLINT;
              // falls through
            }

            if (summary.db_type === pgTypes.SMALLINT && Math.abs(n) > 32767) {
              summary.db_type = pgTypes.INT;
              // falls through
            }

            if (summary.db_type === pgTypes.INT && Math.abs(n) > 2147483648) {
              summary.db_type = pgTypes.BIGINT;
              // falls through
            }

            break pgTypeCheck;
          }

          // Default Case
          summary.db_type = pgTypes.TEXT;
        }

        if (t === "string") {
          v = v.slice(0, 32);
        }

        if (t !== null) {
          ++summary.nonnull;

          // collect a sample of values
          const typeSummary = (summary.types[t] = summary.types[t] || {
            count: 0,
            samples: [],
          });

          ++typeSummary.count;

          if (
            t === "string" &&
            /,/.test(v) &&
            !typeSummary.samples.includes(v)
          ) {
            // Prefer the strings with the most commas in case it should be a PostgreSQL ARRAY
            typeSummary.samples.push(v);

            typeSummary.samples.sort(
              (a, b) =>
                `${b}`.replace(/[^,]/g, "").length -
                `${a}`.replace(/[^,]/g, "").length
            );
            typeSummary.samples.length = Math.min(
              typeSummary.samples.length,
              SAMPLES_LEN
            );
          } else if (
            pgNumericTypes.includes(summary.db_type) &&
            !typeSummary.samples.includes(v)
          ) {
            // Prefer the largest numeric values for deciding numeric column type
            typeSummary.samples.push(v);

            typeSummary.samples.sort((a, b) => +b - +a);
            typeSummary.samples.length = Math.min(
              typeSummary.samples.length,
              SAMPLES_LEN
            );
          } else if (
            typeSummary.samples.length < SAMPLES_LEN &&
            !typeSummary.samples.includes(v)
          ) {
            typeSummary.samples.push(v);
          }
        } else {
          ++summary.null;
        }
      }
    } catch (err) {
      console.error(err);
    }
  }

  return { objectsCount, schemaAnalysis };
}

if (!module.parent) {
  const iter = makeIterFromStdin();

  analyzeSchema([], iter).then((result) => console.log(JSON.stringify(result)));
} else {
  module.exports = analyzeSchema;
}
