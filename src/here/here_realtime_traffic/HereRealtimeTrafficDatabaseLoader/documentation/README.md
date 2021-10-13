# HERE Real Time Traffic Data

## Disk Usage

```sh
npmrds_production=# SELECT nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_total_relation_size(C.oid)) AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE relname like 'here_realtime%'
    AND C.relkind <> 'i'
    AND nspname !~ '^pg_toast'
  ORDER BY pg_total_relation_size(C.oid) DESC
  LIMIT 5;
                                relation                                 | total_size
-------------------------------------------------------------------------+------------
 here_realtime_traffic_partitions.here_realtime_traffic_y2021m10w1d04    | 1898 MB
 here_realtime_traffic_partitions.here_realtime_traffic_y2021m10w1d03    | 1898 MB
 here_realtime_traffic_partitions.here_realtime_traffic_y2021m10w1d05    | 1895 MB
 here_realtime_traffic_partitions.here_realtime_traffic_y2021m10w1d02    | 1152 MB
 here_realtime_traffic_partitions.here_realtime_traffic_y2021m10w1d06h16 | 79 MB
(5 rows)

npmrds_production=# select 1900 * 365;
 ?column?
----------
   693500
(1 row)
```

693GB per year.

```sh
avail@pluto:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            126G     0  126G   0% /dev
tmpfs            26G  2.8M   26G   1% /run
/dev/sda2       7.3T  2.4T  4.6T  34% /
tmpfs           126G   33M  126G   1% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           126G     0  126G   0% /sys/fs/cgroup
/dev/sda1       180M   76M   92M  46% /boot
tmpfs            26G     0   26G   0% /run/user/1000
```
