#!/usr/bin/env node

const csv = require('fast-csv')
const { through } = require('event-stream')
const assert = require('assert')

const travelTimeRE = /travel_time/

const vehicleTypes = {
  'NPMRDS (Trucks and passenger vehicles)': 'all_vehicles',
  'NPMRDS (Passenger vehicles)': 'passenger_vehicles',
  'NPMRDS (Trucks)': 'freight_trucks',
}

const coreInputCols = [
  'datasource',
  'tmc_code', 
  'measurement_tstamp',
  'travel_time_seconds',
]

const coreOutputCols = [
  'tmc',
  'date',
  'epoch',
  'travel_time_all_vehicles',
  'travel_time_passenger_vehicles',
  'travel_time_freight_trucks',
]

const csvInputStream = csv({
  headers: true,
  ignoreEmpty: true,
  discardUnmappedColumns: true,
  strictColumnHandling: true,
  trim: true,
  }).on("data", function(data){
    this.emit(data)
  })
  .on("end", function(){
    this.emit('\n')
  });


let curRow = {}
let curDate = 0
let curEpoch

let auxInputColumns
let auxOutputColumns

function nullOutCurRow () {
  const vehTypes = Object.values(vehicleTypes)
  
  auxOutputColumns = auxOutputColumns
    || auxInputColumns.reduce((acc, col) => acc.concat(vehTypes.map(v => `${col}_${v}`)), [])

  const cols = Array.prototype.concat(coreOutputCols, auxOutputColumns)

  for (let i = 0; i < cols.length; ++i) {
    curRow[cols[i]] = null
  }
}

function getAuxInputColumns (row) {
  return Object.keys(row).filter(c => coreInputCols.indexOf(c) < 0).sort()
}

const transformStream = through(
  function write(data) {
    const tmc = data.tmc_code
    
    if (!auxInputColumns) {
      auxInputColumns = getAuxInputColumns(data)
    }

    if (curRow.tmc !== tmc) {
      if (curRow.tmc) {
        this.emit('data', curRow)
      }
      nullOutCurRow()
    }

    // const timestamp = moment(data.measurement_tstamp, 'YYYY-MM-DD HH:mm:ss')

    const date = +data.measurement_tstamp.slice(0,10).replace(/-/g, '')
    
    assert(curDate <= date, `curDate: ${curDate}, date: ${date}`)

    if (date !== curDate) {
      curDate = date
      curEpoch = 0
    }

    const hour = +data.measurement_tstamp.slice(11, 13)
    const minute = +data.measurement_tstamp.slice(14, 16)

    const epoch = (hour * 12) + Math.floor(minute / 5)

    assert(curEpoch <= epoch)
    assert((epoch >= 0) && (epoch < 288), `
      ERROR with timestamp: ${data.measurement_tstamp}
        tmc: ${tmc}
        epoch: ${epoch}
    `)

    curEpoch = epoch

    curRow.tmc = tmc
    curRow.date = date
    curRow.epoch = epoch

    const vehicleType = vehicleTypes[data.datasource.trim()]

    assert(!!vehicleType)

    curRow[`travel_time_${vehicleType}`] = data.travel_time_seconds

    for (let i = 0; i < auxInputColumns.length; ++i) {
      curRow[`${auxInputColumns[i]}_${vehicleType}`] = data[auxInputColumns[i]]
    }
  },

  function end () {
    this.emit('data', curRow)
    this.emit('end')
  }
)

const csvOutputStream = csv
  .createWriteStream({
    transform: function (obj) {
      return obj
    },
    headers: true,
  })

 
process.stdin
  .pipe(csvInputStream)
  .pipe(transformStream)
  .pipe(csvOutputStream)
  .pipe(process.stdout)
