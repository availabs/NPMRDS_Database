#!/usr/bin/env node

const { env } = process;
const { Client } = require('pg');
const { join } = require('path');
const envFile = require('node-env-file');
const readline = require('readline');
const moment = require('moment');
const minimist = require('minimist');

const argv = minimist(process.argv.slice(2));

// NOTE: TMC, YEAR, and MONTH can be specified as
//    command line args or environment variables.
//    If not specified, the user is prompted for them.
const { TMC, YEAR, MONTH } = argv;

const PHED_AM_PEAK = 'phed_am_peak';
const PHED_PM_PEAK_1 = 'phed_pm_peak_1';
const PHED_PM_PEAK_2 = 'phed_pm_peak_2';

const binEpochExtents = {
  [PHED_AM_PEAK]: [6 * 12, 10 * 12 - 1],
  [PHED_PM_PEAK_1]: [(3 + 12) * 12, (7 + 12) * 12 - 1],
  [PHED_PM_PEAK_2]: [(4 + 12) * 12, (8 + 12) * 12 - 1]
};

const FRIDAY_DOW_AADT_ADJ = 1.1;
const NONFRIDAY_DOW_AADT_ADJ = 1.05;

const configPath = join(__dirname, '../../../config/postgres.env');

envFile(configPath);

const client = new Client();

// https://stackoverflow.com/a/32605063/3970755
function roundTo(n, digits) {
  if (digits === undefined) {
    digits = 0;
  }

  var multiplicator = Math.pow(10, digits);
  n = parseFloat((n * multiplicator).toFixed(11));
  return Math.round(n) / multiplicator;
}

const getTMC = async () => {
  return new Promise((resolve, reject) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question('Enter the tmc (or CTRL-C to quit): ', tmc => {
      rl.close();
      return resolve(tmc);
    });

    rl.on('SIGINT', () => process.exit(0));
  });
};

const getYear = async () => {
  return new Promise((resolve, reject) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question('Enter the data year: ', year => {
      return resolve(+year);
    });

    rl.on('SIGINT', () => process.exit(0));
  });
};

const getMonth = async () => {
  return new Promise((resolve, reject) => {
    const rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });

    rl.question('Enter the data month: ', month => {
      return resolve(+month);
    });

    rl.on('SIGINT', () => process.exit(0));
  });
};

const aggregateTrafficDistToHours = trafficDist =>
  Object.keys(trafficDist).reduce((acc, epoch) => {
    const hour = Math.floor(epoch / 12);
    acc[hour] = (acc[hour] || 0) + trafficDist[epoch];
    return acc;
  }, {});

const getDateExtentsForYrMo = (year, month) => {
  const mm = `0${month}`.slice(-2);

  const startDate = `${year}${mm}01`;
  const endDate = moment(`${year}-${mm}-01`)
    .add(1, 'month')
    .format('YYYYMMDD');

  return [startDate, endDate];
};

const getTMCInfo = async tmc => {
  const q = `
    SELECT
        tmc,
        aadt,
        -- miles to nearest thousandth per measure rule
        -- MAX(60% of speedlimit or 20 mph)
        -- nearest whole second
        ROUND(
          ROUND(
            miles::NUMERIC, 3
          )
          /
          GREATEST(
            avg_speedlimit * 0.6,
            20
          )
          * 
          3600
        )::INT AS excessive_delay_threshold_time_s,
        congestion_level,
        directionality,
        CASE WHEN (faciltype = 1)
          THEN 1
          ELSE 2
        END AS aadt_divisor,
        CASE WHEN (f_system < 3)
          THEN 'FREEWAY'::traffic_dist_functional_class_type
          ELSE 'NONFREEWAY'::traffic_dist_functional_class_type
        END AS functional_class
      FROM tmc_attributes
      WHERE (tmc = $1)
  `;

  const result = await client.query(q, [tmc]);

  return Array.isArray(result && result.rows) && result.rows.length === 1
    ? result.rows[0]
    : null;
};

const getTrafficDist = async ({
  congestion_level,
  directionality,
  functional_class
}) => {
  const q = `
    SELECT 
        epoch,
        percent_daily_volume
      FROM traffic_distributions
      WHERE (
        (day_type = 'WEEKDAY'::traffic_dist_day_type) -- PHED only concerned with weekdays
        AND
        (congestion_level = $1::traffic_dist_congestion_level_type)
        AND
        (directionality = $2::traffic_dist_directionality_type)
        AND
        (functional_class = $3::traffic_dist_functional_class_type)
      )
  `;

  const result = await client.query(q, [
    congestion_level,
    directionality,
    functional_class
  ]);

  return result.rows.reduce((acc, { epoch, percent_daily_volume }) => {
    acc[epoch] = percent_daily_volume;
    return acc;
  }, {});
};

const getNPMRDSData = async (tmc, year, month) => {
  const [startDate, endDate] = getDateExtentsForYrMo(year, month);

  const amEpochs = binEpochExtents[PHED_AM_PEAK];
  const pmEpochs = [
    binEpochExtents[PHED_PM_PEAK_1][0],
    binEpochExtents[PHED_PM_PEAK_2][1]
  ];

  const q = `
    SELECT
        date,
        epoch,
        travel_time_all_vehicles
      FROM npmrds
      WHERE (
        (tmc = $1)
        AND
        (date >= $2::date AND date < $3::date)
        AND
        (EXTRACT(DOW FROM date) BETWEEN 1 AND 5)
        AND
        (
          (epoch BETWEEN ${amEpochs[0]} AND (${amEpochs[1]}))
          OR
          (epoch BETWEEN ${pmEpochs[0]} AND (${pmEpochs[1]}))
        )
        AND ( -- We have a valid travel time.
          (travel_time_all_vehicles <> 0)
          AND
          (travel_time_all_vehicles IS NOT NULL)
        )
      )
      ORDER BY date, epoch
  `;

  const result = await client.query(q, [tmc, startDate, endDate]);

  return result.rows;
};

const binNPMRDSData = npmrdsData => ({
  [PHED_AM_PEAK]: npmrdsData.filter(
    ({ epoch }) =>
      epoch >= binEpochExtents[PHED_AM_PEAK][0] &&
      epoch <= binEpochExtents[PHED_AM_PEAK][1]
  ),
  [PHED_PM_PEAK_1]: npmrdsData.filter(
    ({ epoch }) =>
      epoch >= binEpochExtents[PHED_PM_PEAK_1][0] &&
      epoch <= binEpochExtents[PHED_PM_PEAK_1][1]
  ),
  [PHED_PM_PEAK_2]: npmrdsData.filter(
    ({ epoch }) =>
      epoch >= binEpochExtents[PHED_PM_PEAK_2][0] &&
      epoch <= binEpochExtents[PHED_PM_PEAK_2][1]
  )
});

const harmonicMean = arr => arr.length / arr.reduce((acc, n) => acc + 1 / n, 0);

const getBinnedQtrHourMeans = npmrdsDataBinned =>
  Object.keys(npmrdsDataBinned).reduce((acc1, bin) => {
    const d = npmrdsDataBinned[bin];

    const qtrHourArrs = d.reduce(
      (acc2, { date, epoch, travel_time_all_vehicles }) => {
        if (!travel_time_all_vehicles) {
          return acc2;
        }

        const qtrHr = Math.floor(epoch / 3);

        acc2[date] = acc2[date] || {};
        acc2[date][qtrHr] = acc2[date][qtrHr] || [];

        acc2[date][qtrHr].push(travel_time_all_vehicles);

        return acc2;
      },
      {}
    );

    const qtrHourMeans = Object.keys(qtrHourArrs).reduce((acc2, date) => {
      const means = Object.keys(qtrHourArrs[date])
        .map(n => +n)
        .sort()
        .map(qtrHr => ({
          date,
          qtrHr,
          meanTravelTime: harmonicMean(qtrHourArrs[date][qtrHr])
        }));

      return acc2.concat(means);
    }, []);

    acc1[bin] = qtrHourMeans;

    return acc1;
  }, {});

const getBinnedXDelayHrs = (
  qtrHourMeansBinned,
  { excessive_delay_threshold_time_s: thresholdTime }
) =>
  Object.keys(qtrHourMeansBinned).reduce((acc, bin) => {
    const d = qtrHourMeansBinned[bin];

    const xDelays = d
      .map(({ date, qtrHr, meanTravelTime }) => ({
        date,
        qtrHr,
        xDelayHrs: roundTo(
          Math.min(meanTravelTime - thresholdTime, 900) / 3600,
          3
        )
      }))
      .filter(({ xDelayHrs }) => xDelayHrs > 0);

    acc[bin] = xDelays;

    return acc;
  }, {});

const getBinnedVehicleHourDelays = async (xDelayHrsBinned, tmcInfo) => {
  const trafficDist = await getTrafficDist(tmcInfo);
  const traffDistByHour = aggregateTrafficDistToHours(trafficDist);

  const { aadt, aadt_divisor } = tmcInfo;

  const directionalAADT = aadt / aadt_divisor;

  const binnedVehicleHourDelays = Object.keys(xDelayHrsBinned).reduce(
    (acc1, bin) => {
      const d = xDelayHrsBinned[bin];

      const vehicleHourDelays = d.reduce((acc2, { date, qtrHr, xDelayHrs }) => {
        const day = new Date(date).getDay();
        const dowAdjFactor =
          day === 'Friday' ? FRIDAY_DOW_AADT_ADJ : NONFRIDAY_DOW_AADT_ADJ;

        const hr = Math.floor(qtrHr / 4);
        const vehDist = traffDistByHour[hr] / 4 / 100;

        const estVehCount = vehDist * directionalAADT * dowAdjFactor;

        return acc2 + estVehCount * xDelayHrs;
      }, 0);

      acc1[bin] = vehicleHourDelays;
      return acc1;
    },
    {}
  );

  return binnedVehicleHourDelays;
};

const logData = d =>
  d.forEach(row => {
    const formattedRow = Object.keys(row)
      .sort()
      .reduce((acc, c) => {
        const v =
          row[c] && row[c].toString ? row[c].toString().slice(0, 12) : row[c];
        const f = '               ' + v;
        return `${acc}${f.slice(-15)}`;
      }, '');
    console.log(formattedRow);
  });

const doIt = async () => {
  await client.connect();

  const tmc = TMC || env.TMC || (await getTMC());
  const year = YEAR || env.YEAR || (await getYear());
  const month = MONTH || env.MONTH || (await getMonth());

  const tmcInfo = await getTMCInfo(tmc);

  // console.log(JSON.stringify(tmcInfo, null, 4));

  const npmrdsData = await getNPMRDSData(tmc, year, month);

  const npmrdsDataBinned = binNPMRDSData(npmrdsData);

  const qtrHourMeansBinned = getBinnedQtrHourMeans(npmrdsDataBinned);

  // logData(
  // qtrHourMeansBinned[PHED_AM_PEAK].slice().sort(
  // (a, b) => +a.meanTravelTime - +b.meanTravelTime
  // )
  // );

  const xDelayHrsBinned = getBinnedXDelayHrs(qtrHourMeansBinned, tmcInfo);

  const vehicleHourDelaysBinned = await getBinnedVehicleHourDelays(
    xDelayHrsBinned,
    tmcInfo
  );

  console.log(JSON.stringify(vehicleHourDelaysBinned, null, 4));

  client.end();
};

doIt();
