# 2020 NPMRDS Truck AADT

We noticed that in the 2020 NPMRDS TMC metadata file *(TMC_Identification.csv)*,
  **the Single-Unit Truck AADT *(aadt\_singl)* and
  the Combination Truck AADT *(aadt\_combi)* columns
  appear to have been transposed.**
  
## 2019 v 2020 Truck AADT values

Specifically, we found the following:

* 2019 *aadt\_singl* = 2020 *aadt\_singl* and 2019 *aadt\_combi* = 2020 *aadt\_combi*
  for **13** TMCs.

* 2019 *aadt\_singl* = 2020 *aadt\_combi* and 2019 *aadt\_combi* = 2020 *aadt\_singl*
  for **816** TMCs.

* 2019 *aadt\_singl* and 2020 *aadt\_singl* are closer in value
    than 2019 *aadt\_singl* and 2020 *aadt\_combi* for **1142** TMCs.

* 2019 *aadt\_singl* and 2020 *aadt\_combi* are closer in value
    than 2019 *aadt\_singl* and 2020 *aadt\_singl* for **19,464** TMCs.

## PM3 measure calculations dependencies on Truck AADT

The *Average Vehicle Occupancy Factor* (**AVO**) is required in both the
  PM3 *Level of Travel Time Reliability* (**LOTTR**) and the
  *Peak Hour Excessive Delay* (**PHED**) calculations.

See: [
  Federal Highway Administration
  National Performance Management Measures
  Final Rule
](https://www.govinfo.gov/content/pkg/FR-2017-01-18/pdf/2017-00681.pdf)

The AVO factor calculation requires the TMC *aadt*, *aadt_singl*,
  and *aadt_combi* values.

See: [
  Average Vehicle Occupancy Factors for
  Computing Travel Time Reliability
  Measures and Total Peak Hour Excessive
  Delay Metrics (April 2018)
](https://www.fhwa.dot.gov/tpm/guidance/avo_factors.pdf)

Therefore, the PM3 LOTTR and PHED measures depend, indirectly, on the
  *aadt_singl* and *aadt_combi* values. If they are, in fact, transposed,
  these two measures would be affected by the error.

## Impact

If it is the case that the *aadt_singl* and *aadt_combi* values are
  transposed in the 2020 TMC_Identification.csv file,
  then the following is the effect on the aggregate 2020 PM3 calculations
  for NYS.


