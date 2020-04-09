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
    The four digits of the year the
    data represents.
  */
  ({ Year_Record }) =>
    typeof Year_Record === 'number' &&
    Year_Record >= 2016 &&
    Year_Record <= CURRENT_YEAR
      ? null
      : { Year_Record },
  /*
    Up to two digits for the FIPS
    code. See Appendix C of the
    HPMS Field Manual for a
    complete list of eligible codes.
  */
  ({ State_Code }) =>
    typeof State_Code === 'number' && State_Code > 0 && State_Code <= 99
      ? null
      : { State_Code },

  /*
    Alpha-numeric code used to
    identify the reporting segment
    location on a given route.
  */
  ({ Travel_Time_Code }) =>
    typeof Travel_Time_Code === 'string' && Travel_Time_Code.length === 9
      ? null
      : { Travel_Time_Code },

  /*
    1 - Interstate
    2 - Principal Arterial – Other Freeways and Expressways
    3 - Principal Arterial – Other
    4 - Minor Arterial
    5 - Major Collector
    6 - Minor Collector
    7 - Local
  */
  ({ F_System }) =>
    [1, 2, 3, 4, 5, 6, 7].includes(F_System) ? null : { F_System },

  /*
    Up to five digits for the Census urban code. See Appendix I of
    the HPMS Field Manual for a complete list of eligible codes.
  */
  ({ Urban_Code }) =>
    typeof Urban_Code === 'number' && Urban_Code >= 0 && Urban_Code <= 99999
      ? null
      : { Urban_Code },

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
  ({ Facility_Type }) =>
    [1, 2, 6].includes(Facility_Type) ? null : { Facility_Type },

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
  ({ Segment_Length }) =>
    typeof Segment_Length === 'number' &&
    (`${Segment_Length}`.split('.')[1] || '').length <= 3
      ? null
      : { Segment_Length },

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
  ({ DIR_AADT }) =>
    DIR_AADT > 0 && `${DIR_AADT}`.split('.')[1] === undefined
      ? null
      : { DIR_AADT },

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
  ({ LOTTR_AMP }) =>
    typeof LOTTR_AMP === 'number' &&
    LOTTR_AMP >= 1 &&
    (`${LOTTR_AMP}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTR_AMP },

  /*
    50th percentile travel
    time for “AM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_AMP50PCT'),

  /*
    80th percentile travel
    time for “AM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_AMP80PCT'),

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
  ({ LOTTR_MIDD }) =>
    typeof LOTTR_MIDD === 'number' &&
    LOTTR_MIDD >= 1 &&
    (`${LOTTR_MIDD}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTR_MIDD },

  /*
    50th percentile travel
    time for “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  ({ TT_MIDD50PCT }) =>
    typeof TT_MIDD50PCT === 'number' &&
    TT_MIDD50PCT >= 0 &&
    `${TT_MIDD50PCT}`.split('.')[1] === undefined
      ? null
      : {},
  newPctTimeValidator('TT_MIDD50PCT'),

  /*
    80th percentile travel
    time for “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_MIDD80PCT'),

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
  ({ LOTTR_PMP }) =>
    typeof LOTTR_PMP === 'number' &&
    LOTTR_PMP >= 1 &&
    (`${LOTTR_PMP}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTR_PMP },

  /*
    50th percentile travel
    time for “PM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_PMP50PCT'),

  /*
    80th percentile travel
    time for “PM Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_PMP80PCT'),

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
  ({ LOTTR_WE }) =>
    typeof LOTTR_WE === 'number' &&
    LOTTR_WE >= 1 &&
    (`${LOTTR_WE}`.split('.')[1] || '').length <= 2
      ? null
      : { LOTTR_WE },

  /*
    50th percentile travel
    time for “Weekend”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_WE50PCT'),

  /*
    80th percentile travel
    time for “Weekend”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TT_WE80PCT'),

  /*
    Truck Travel Time
    Reliability (TTTR)
    metric for “AM Peak.”

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTR_AMP }) =>
    typeof TTTR_AMP === 'number' &&
    TTTR_AMP >= 1 &&
    (`${TTTR_AMP}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTR_AMP },

  /*
    50th percentile truck
    travel time for “AM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_AMP50PCT'),

  /*
    95th percentile truck
    travel time for “AM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_AMP95PCT'),

  /*
    TTTR metric for
    “Midday.”

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTR_MIDD }) =>
    typeof TTTR_MIDD === 'number' &&
    TTTR_MIDD >= 1 &&
    (`${TTTR_MIDD}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTR_MIDD },

  /*
    50th percentile truck
    travel time for
    “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_MIDD50PCT'),

  /*
    95th percentile truck
    travel time for
    “Midday”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_MIDD95PCT'),

  /*
    Truck Travel Time
    Reliability (TTTR)
    metric for “PM Peak.”

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTR_PMP }) =>
    typeof TTTR_PMP === 'number' &&
    TTTR_PMP >= 1 &&
    (`${TTTR_PMP}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTR_PMP },

  /*
    50th percentile truck
    travel time for “PM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_PMP50PCT'),

  /*
    95th percentile truck
    travel time for “PM
    Peak”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_PMP95PCT'),

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
  ({ TTTR_OVN }) =>
    typeof TTTR_OVN === 'number' &&
    TTTR_OVN >= 1 &&
    (`${TTTR_OVN}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTR_OVN },

  /*
    50th percentile truck
    travel time for
    “Overnight”

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_OVN50PCT'),

  /*
    95th percentile truck
    travel time for
    “Overnight” 

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_OVN95PCT'),

  /*
    TTTR metric for
    “Weekend.” 

    A positive non-negative, nonzero number (rounded to the
    nearest hundredth); must be
    >= 1.00
  */
  ({ TTTR_WE }) =>
    typeof TTTR_WE === 'number' &&
    TTTR_WE >= 1 &&
    (`${TTTR_WE}`.split('.')[1] || '').length <= 2
      ? null
      : { TTTR_WE },

  /*
    50th percentile truck
    travel time for
    “Weekend” 

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_WE50PCT'),

  /*
    95th percentile truck
    travel time for
    “Weekend” 

    A positive non-negative, nonzero number (in units of
    seconds rounded to the
    nearest integer); must be >= 0
  */
  newPctTimeValidator('TTT_WE95PCT'),

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
  ({ OCC_FAC }) =>
    typeof OCC_FAC === 'number' &&
    OCC_FAC >= 1 &&
    (`${OCC_FAC}`.split('.')[1] || '').length <= 1
      ? null
      : { OCC_FAC },

  /*
    Travel time metric
    data source

    1 – NPRMRDS
    2 – “Equivalent” Travel Time
    Data Set
  */
  ({ METRIC_SOURCE }) =>
    typeof METRIC_SOURCE === 'number' && [1, 2].includes(METRIC_SOURCE)
      ? null
      : { METRIC_SOURCE },

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
