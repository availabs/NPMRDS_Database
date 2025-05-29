// https://www.fhwa.dot.gov/tpm/guidance/pm3_hpms.pdf

const _ = require('lodash');

const CURRENT_YEAR = new Date().getFullYear();

// Same rule for all LOTTR and TTTR time percentile cols.
const newPctTimeValidator = k => ({ [k]: v }) =>
  typeof v === 'number' && v >= 0 && `${v}`.split('.')[1] === undefined
    ? null
    : { [k]: v };

const validators = [
  /*
    MM/DD/YYYY
  */
  ({ BeginDate }) =>
    typeof BeginDate === 'string' &&
    BeginDate.length === 10 &&
    parseInt(BeginDate.slice(-4)) >= 2016 &&
    parseInt(BeginDate.slice(-4)) <= CURRENT_YEAR
      ? null
      : { BeginDate },
  /*
    Up to two digits for the FIPS
    code. See Appendix C of the
    HPMS Field Manual for a
    complete list of eligible codes.
  */
  ({ StateCode }) =>
    typeof StateCode === 'number' && StateCode > 0 && StateCode <= 99
      ? null
      : { StateCode },

  /*
    Alpha-numeric code used to
    identify the reporting segment
    location on a given route.
  */
  ({ TravelTimeCode }) =>
    typeof TravelTimeCode === 'string' && TravelTimeCode.length === 9
      ? null
      : { TravelTimeCode },

  /*
    1 - Interstate
    2 - Principal Arterial – Other Freeways and Expressways
    3 - Principal Arterial – Other
    4 - Minor Arterial
    5 - Major Collector
    6 - Minor Collector
    7 - Local
  */
  ({ FSystem }) =>
    [1, 2, 3, 4, 5, 6, 7].includes(FSystem) ? null : { FSystem },

  /*
    Up to five digits for the Census urban code. See Appendix I of
    the HPMS Field Manual for a complete list of eligible codes.
  */
  ({ UrbanCode }) =>
    typeof UrbanCode === 'number' && UrbanCode >= 0 && UrbanCode <= 99999
      ? null
      : { UrbanCode },

  /*
    Operational
    characteristic of the
    roadway. See Chapter
    4 of the HPMS Field
    Manual for additional
    information.

    1 - One-Way Roadway
    2 - Two-Way Roadway
    6 - Non-Inventory Direction
  */
  ({ FacilityType }) =>
    [1, 2, 6].includes(FacilityType) ? null : { FacilityType },

  /*
    FHWA-approved NHS.
    See Chapter 4 of the
    HPMS Field Manual
    for additional
    information.

     1 - Non Connector NHS
     2 - Major Airport
     3 - Major Port Facility
     4 - Major Amtrak Station
     5 - Major Rail/Truck Terminal
     6 - Major Inter City Bus Terminal
     7 – Major Public Transportation or MultiModal Passenger Terminal
     8 - Major Pipeline Terminal
     9 - Major Ferry Terminal
    -1 – the entire length of a reporting segment is not on
         mainline NHS or the entire length of a reporting
         segment overlaps with other reporting segment(s).
  */
  ({ NHS }) => ([-1, 1, 2, 3, 4, 5, 6, 7, 8, 9].includes(NHS) ? null : { NHS }),

  /*
    Reporting segment
    length from Travel
    time data set
    Only report the length
    on the NHS.

    Decimal value rounded to the
    nearest thousandth of a mile.
  */
  ({ SegmentLength }) =>
    typeof SegmentLength === 'number' &&
    (`${SegmentLength}`.split('.')[1] || '').length <= 3
      ? null
      : { SegmentLength },

  /*
    Direction of travel
    associated with the
    reporting segment
    from Travel time data
    set

    1 – Northbound
    2 – Southbound
    3 – Eastbound
    4 – Westbound
    5 - Other
  */
  ({ Directionality }) =>
    typeof Directionality === 'number' &&
    [1, 2, 3, 4, 5].includes(Directionality)
      ? null
      : { Directionality },

  /*
    Annual Average Daily
    Traffic (for a given
    direction of travel) on
    a reporting segment

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be > 0
  */
  ({ DIRAADT }) =>
    DIRAADT > 0 && `${DIRAADT}`.split('.')[1] === undefined
      ? null
      : { DIRAADT },

  /*
    Level of travel time
    reliability (LOTTR)
    metric for “AM Peak.”
    “AM Peak” is between
    the hours of 6:00 a.m.
    and 10:00 a.m. for
    every weekday
    (Monday through
    Friday) from January
    1st through December
    31st of the same
    calendar year.

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
   */
  ({ LOTTRAMP }) =>
    typeof LOTTRAMP === 'number' &&
    LOTTRAMP >= 1 &&
    (`${LOTTRAMP}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTRAMP },

  /*
    50th percentile travel
    time for “AM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTAMP50PCT'),

  /*
    80th percentile travel
    time for “AM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTAMP80PCT'),

  /*
    LOTTR metric for
    “Midday.” “Midday”
    is between the hours
    of 10:00 a.m. and 4:00
    p.m. for every
    weekday (Monday
    through Friday) from
    January 1st through
    December 31st of the
    same calendar year.

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
   */
  ({ LOTTRMIDD }) =>
    typeof LOTTRMIDD === 'number' &&
    LOTTRMIDD >= 1 &&
    (`${LOTTRMIDD}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTRMIDD },

  /*
    50th percentile travel
    time for “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  ({ TTMIDD50PCT }) =>
    typeof TTMIDD50PCT === 'number' &&
    TTMIDD50PCT >= 0 &&
    `${TTMIDD50PCT}`.split('.')[1] === undefined
      ? null
      : {},
  newPctTimeValidator('TTMIDD50PCT'),

  /*
    80th percentile travel
    time for “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTMIDD80PCT'),

  /*
    LOTTR metric for “PM
    Peak.” “PM Peak” is
    between the hours of
    4:00 p.m. and 8:00
    p.m. for every
    weekday (Monday
    through Friday) from
    January 1st through
    December 31st of the
    same calendar year.

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
   */
  ({ LOTTRPMP }) =>
    typeof LOTTRPMP === 'number' &&
    LOTTRPMP >= 1 &&
    (`${LOTTRPMP}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTRPMP },

  /*
    50th percentile travel
    time for “PM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTPMP50PCT'),

  /*
    80th percentile travel
    time for “PM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTPMP80PCT'),

  /*
    LOTTR metric for
    “Weekend.”
    “Weekend” is
    between the hours of
    6:00 a.m. and 8:00
    p.m. for every
    weekend day
    (Saturday and Sunday)
    from January 1st
    through December
    31st of the same
    calendar year.

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ LOTTRWE }) =>
    typeof LOTTRWE === 'number' &&
    LOTTRWE >= 1 &&
    (`${LOTTRWE}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTRWE },

  /*
    50th percentile travel
    time for “Weekend”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTWE50PCT'),

  /*
    80th percentile travel
    time for “Weekend”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTWE80PCT'),

  /*
    Truck Travel Time
    Reliability (TTTR)
    metric for “AM Peak.”

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTRAMP }) =>
    typeof TTTRAMP === 'number' &&
    TTTRAMP >= 1 &&
    (`${TTTRAMP}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTRAMP },

  /*
    50th percentile truck
    travel time for “AM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTAMP50PCT'),

  /*
    95th percentile truck
    travel time for “AM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTAMP95PCT'),

  /*
    TTTR metric for
    “Midday.”

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTRMIDD }) =>
    typeof TTTRMIDD === 'number' &&
    TTTRMIDD >= 1 &&
    (`${TTTRMIDD}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTRMIDD },

  /*
    50th percentile truck
    travel time for
    “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTMIDD50PCT'),

  /*
    95th percentile truck
    travel time for
    “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTMIDD95PCT'),

  /*
    Truck Travel Time
    Reliability (TTTR)
    metric for “PM Peak.”

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTRPMP }) =>
    typeof TTTRPMP === 'number' &&
    TTTRPMP >= 1 &&
    (`${TTTRPMP}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTRPMP },

  /*
    50th percentile truck
    travel time for “PM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTPMP50PCT'),

  /*
    95th percentile truck
    travel time for “PM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTPMP95PCT'),

  /*
    TTTR metric for
    “Overnight.”
    “Overnight” is
    between the hours of
    8:00 p.m. and 6:00
    a.m. for everyday
    (Sunday through
    Saturday) from
    January 1st through
    December 31st of the
    same calendar year.

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTROVN }) =>
    typeof TTTROVN === 'number' &&
    TTTROVN >= 1 &&
    (`${TTTROVN}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTROVN },

  /*
    50th percentile truck
    travel time for
    “Overnight”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTOVN50PCT'),

  /*
    95th percentile truck
    travel time for
    “Overnight” 

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTOVN95PCT'),

  /*
    TTTR metric for
    “Weekend.” 

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTRWE }) =>
    typeof TTTRWE === 'number' &&
    TTTRWE >= 1 &&
    (`${TTTRWE}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTRWE },

  /*
    50th percentile truck
    travel time for
    “Weekend” 

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTWE50PCT'),

  /*
    95th percentile truck
    travel time for
    “Weekend” 

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTTWE95PCT'),

  /*
    Total peak hour
    excessive delay
    (PHED) metric

    A positive non-negative, nonzero number (in units of
    person-hours, rounded to the
    nearest thousandths) 
  */
  ({ PHED }) =>
    typeof PHED === 'number' &&
    PHED >= 0 &&
    (`${PHED}`.split('.')[1] || '').length <= 3
      ? null
      : { PHED },

  /*
    Average vehicle
    occupancy factor

    A positive non-negative, nonzero number (rounded to the
    nearest tenth); must be >= 1.0. 
  */
  ({ OCCFAC }) =>
    typeof OCCFAC === 'number' &&
    OCCFAC >= 1 &&
    (`${OCCFAC}`.split('.')[1] || '').length <= 1
      ? null
      : { OCCFAC },

  /*
    Travel time metric
    data source

    1 – NPRMRDS
    2 – “Equivalent” Travel Time
    Data Set
  */
  ({ MetricSource }) =>
    typeof MetricSource === 'number' && [1, 2].includes(MetricSource)
      ? null
      : { MetricSource },

  /*
    Comment for state
    use

    Variable text up to 100
    characters.
  */
  ({ COMMENTS }) =>
    typeof COMMENTS === 'string' && COMMENTS.length <= 100 ? null : { COMMENTS }
];

const getRowInvalidColValues = row => {
  const invalidColValues = Object.assign(
    {},
    ...validators.map(v => v(row)).filter(v => v !== null)
  );
  return _.isEmpty(invalidColValues) ? null : invalidColValues;
};

module.exports = getRowInvalidColValues;
