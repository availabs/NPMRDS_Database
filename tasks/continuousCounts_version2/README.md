## Vehicle Class
```
1   COUNT_ID                     "020011_09012016"
2   REGION                       "11"
3   REGION_CODE                  0
4   COUNTY_CODE                  2
5   STATION                      "0011"
6   RCSTA                        "020011"
7   FUNCTIONAL_CLASS             11
8   FACTOR_GROUP                 30
9   LATITUDE                     ""
10  LONGITUDE                    ""
11  SPECIFIC_RECORDER_PLACEMENT  "                  "
12  CHANNEL_NOTES                "0                 "
13  DATA_TYPE                    "Class             Data"
14  BLANK                        ""
15  YEAR                         2016
16  MONTH                        9
17  DAY                          1
18  DAY_OF_WEEK                  "Thursday"
19  FEDERAL_DIRECTION            1
20  LANE_CODE                    1
21  LANES_IN_DIRECTION           3
22  COLLECTION_INTERVAL          60
23  DATA_INTERVAL                15.1
24  CLASS_F1
25  CLASS_F2
26  CLASS_F3
27  CLASS_F4
28  CLASS_F5
29  CLASS_F6
30  CLASS_F7
31  CLASS_F8
32  CLASS_F9
33  CLASS_F10
34  CLASS_F11
35  CLASS_F12
36  CLASS_F13
37  UNCLASSIFIED
38  TOTAL                        0
39  FLAG_FIELD                   ""
40  BATCH_ID                     284347
```

```
$ tail -n+3 Continuous_Class_2015-2019.CSV|head -1| tr , '\n'
"020011_09012016"
"11"
0
2
"0011"
"020011"
11
30
""
""
"                            "
"0                                                 "
"Class Data"
""
2016
9
1
"Thursday"
1
1
3
60
15.1














0
""
284347

$ tail -n+3 Continuous_Class_2015-2019.CSV|head -1|sed 's/ \{1,\}/ /g; s/ \{0,\}"/"/g; s/""//g' | tr , '\n'
"020011_09012016"
"11"
0
2
"0011"
"020011"
11
30



"0"
"Class Data"

2016
9
1
"Thursday"
1
1
3
60
15.1














0

284347
```

## Volume


