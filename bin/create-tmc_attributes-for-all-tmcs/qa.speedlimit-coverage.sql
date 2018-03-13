SELECT
    abbreviation AS state,
    ROUND (
      COUNT(avg_speedlimit)::NUMERIC
      /
      COUNT(1)::NUMERIC
      *
      100,

      3
    ) AS coverage_pct
  FROM inrix_shapefile AS shp
    INNER JOIN state_abbreviations AS abv
      ON (shp.state = abv.state_name)
    LEFT OUTER JOIN avg_speedlimits asl USING (tmc)
  GROUP BY abbreviation
  ORDER BY state
;

/*
----- BEFORE ANY BACKFILLING -----

 state | coverage_pct
-------+--------------
 ak    |       29.128
 al    |       38.977
 ar    |       38.206
 az    |       41.145
 ca    |       37.501
 co    |       41.561
 ct    |       32.926
 dc    |       36.528
 de    |       44.664
 fl    |       36.186
 ga    |       38.720
 hi    |       40.774
 ia    |       31.161
 id    |       34.696
 il    |       34.123
 in    |       31.391
 ks    |       35.361
 ky    |       37.840
 la    |       38.191
 ma    |       36.599
 md    |       38.990
 me    |       33.053
 mi    |       28.314
 mn    |       32.744
 mo    |       39.506
 ms    |       45.159
 mt    |       37.558
 nc    |       38.231
 nd    |       27.953
 ne    |       33.144
 nh    |        0.584
 nj    |       37.454
 nm    |       38.711
 nv    |       39.639
 ny    |       95.110
 oh    |       33.278
 ok    |       37.436
 or    |       35.667
 pa    |       33.613
 ri    |       35.363
 sc    |       40.859
 sd    |       30.840
 tn    |       10.879
 tx    |       38.937
 ut    |       33.453
 va    |       38.099
 vt    |       36.041
 wa    |       33.579
 wi    |       35.851
 wv    |       35.215
 wy    |       36.120
(51 rows)

----- AFTER REGEX BACKFILLING -----

 state | coverage_pct
-------+--------------
 ak    |       91.121
 al    |       92.115
 ar    |       99.357
 az    |       90.847
 ca    |       87.007
 co    |       98.595
 ct    |       88.390
 dc    |       88.452
 de    |       96.988
 fl    |       85.162
 ga    |       92.622
 hi    |       92.339
 ia    |       95.382
 id    |       98.918
 il    |       91.762
 in    |       92.819
 ks    |       93.435
 ky    |       93.741
 la    |       90.532
 ma    |       91.615
 md    |       90.007
 me    |       98.599
 mi    |       93.334
 mn    |       89.939
 mo    |       91.844
 ms    |       97.554
 mt    |       99.586
 nc    |       89.284
 nd    |       99.460
 ne    |       93.919
 nh    |        1.328
 nj    |       37.454
 nm    |       93.498
 nv    |       89.148
 ny    |       95.112
 oh    |       93.178
 ok    |       91.776
 or    |       98.767
 pa    |       91.463
 ri    |       94.765
 sc    |       94.554
 sd    |       99.542
 tn    |       25.226
 tx    |       92.202
 ut    |       86.901
 va    |       88.821
 vt    |       98.818
 wa    |       88.865
 wi    |       93.346
 wv    |       98.388
 wy    |       99.180
(51 rows)


----- AFTER SPATIAL BACKFILLING -----

*/
