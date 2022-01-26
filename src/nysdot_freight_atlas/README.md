# NYDOT FreightAtlas GeoDatabase Loading

```sh
  $ ogrinfo -al -so Map_Data05232016.gdb \
    | grep 'Layer name' \
    | awk '{ print $3 }' \
    | sort

  Border_Crossing_Port
  Border_States
  Canada
  CAN_adm1
  Capital_Region
  Central_Region
  Cities_PopOver20kAnno
  City_Town
  Class1
  Class2
  Class3
  CommuterICP
  County
  Highways
  HighwaysAnno
  Intermodal_Facility
  Interstate
  InterstateAnno
  InterstateAnno2
  InterstateAnno3
  InterstateAnno4
  InterstateAnno5
  Major_Airport
  Major_Ports
  MarineHighways
  MPO_Boundary
  MPO_Cities
  MPO_Cities_Anno
  MPO_Cities_Resize
  nhd24kwb_a_ny
  NHPN
  NHS
  NTAD_2014_NYarea
  NYMTC_HudsonValleyRegion
  NYS_Canal_System
  NYSDOT_Regions
  Pipelines
  PipelineTerminals
  Pop20k_Cities_Resize
  Primary_Freight_Network
  SelectCities_PopOver20k
  State
  Terminal
  Western_Region
```
