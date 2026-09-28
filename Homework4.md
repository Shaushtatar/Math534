HW4
================
William Harris
2026-09-28

Question 2:

``` r
con <- dbConnect(
  MariaDB(), host = "scidb.smith.edu",
  user = "waiuser", password = "smith_waiDB", 
  dbname = "wai"
)
Measurements <- tbl(con, "Measurements")
dbGetQuery(con, "SELECT COUNT(*) FROM Measurements") #Getting the row count
```

    ##   COUNT(*)
    ## 1  5052304

``` r
dbDisconnect(con)
```

There are 5,052,304 rows in the “measurements” table. Wowie zowie!

Question 3:

``` r
con <- dbConnect_scidb("airlines")
dbGetQuery(con, "SELECT year, COUNT(*) AS n
            FROM flights
            GROUP BY year;")
```

    ##   year       n
    ## 1 2013 6369482
    ## 2 2014 5819811
    ## 3 2015 5819079

There are observations from from 2013, 2014, and 2015.

``` r
#tbl(con, "flights")
```

Question 4: Q4.1:

``` r
dbGetQuery(con, "SELECT COUNT(*) FROM flights
           WHERE year = 2015 AND month = 5 AND day = 14
           AND dest = 'DFW'
           ")
```

    ##   COUNT(*)
    ## 1      737

737 flights flew into Dallas Fort Worth on May 14th, 2015

Q4.2:

``` r
dbGetQuery(con, "SELECT dest, COUNT(*) 
           FROM flights
           WHERE year = 2015
           AND origin = 'ORD'
           GROUP BY dest
           ORDER BY COUNT(*) DESC
           LIMIT 0,10") #top 10 results
```

    ##    dest COUNT(*)
    ## 1   LGA    10492
    ## 2   LAX     8720
    ## 3   DFW     8384
    ## 4   SFO     8156
    ## 5   BOS     7240
    ## 6   ATL     7104
    ## 7   MSP     6955
    ## 8   DCA     6495
    ## 9   DEN     6120
    ## 10  MKE     5274

Of all domestic flights going out from Chicago O’Hare in 2015, the most
common destinations were LaGuardia, Los Angeles, Dallas Fort Worth, San
Francisco International, and Boston Logan International. This is about
what I would guess are the most popular domestic destinations.

Q4.3:

``` r
dbGetQuery(con, "SELECT dest, AVG(arr_delay) AS avg_delay 
           FROM flights
           WHERE year = 2015
           GROUP BY dest
           ORDER BY avg_delay DESC
           LIMIT 0,10")
```

    ##    dest avg_delay
    ## 1   STC   21.6220
    ## 2   ILG   21.3163
    ## 3   OTH   17.0868
    ## 4   TTN   15.7600
    ## 5   PBG   15.3559
    ## 6   GUM   14.3671
    ## 7   ASE   14.3334
    ## 8   MQT   14.1420
    ## 9   BPT   12.9792
    ## 10  BQN   11.6724

The highest average delays in arrivals in 2015 was St. Cloud in
Minnesota.

Q4.4:

``` r
dbGetQuery(con, "SELECT COUNT(*) FROM flights
           WHERE year = 2015 AND
           (dest = 'BDL'
           OR origin = 'BDL')
           ")
```

    ##   COUNT(*)
    ## 1    41025

41,025 flights went into or out of BDL in 2015.

Q4.5:

``` r
dbGetQuery(con, "SELECT carrier, flight FROM flights
           WHERE year = 2015 AND month = 9 AND day = 26 AND
           ((dest = 'LAX' AND origin = 'JFK') 
           OR (origin = 'LAX'AND dest = 'JFK'))
           ")
```

    ##    carrier flight
    ## 1       UA    441
    ## 2       B6     24
    ## 3       VX    399
    ## 4       DL   1908
    ## 5       B6     23
    ## 6       AA    118
    ## 7       DL    476
    ## 8       VX    404
    ## 9       AA     34
    ## 10      AA     33
    ## 11      UA    275
    ## 12      DL    472
    ## 13      UA   1985
    ## 14      AA      2
    ## 15      B6    123
    ## 16      B6    124
    ## 17      DL    412
    ## 18      VX    407
    ## 19      AA    255
    ## 20      VX    406
    ## 21      UA    779
    ## 22      B6    223
    ## 23      B6    224
    ## 24      UA    703
    ## 25      AA      4
    ## 26      DL    423
    ## 27      AA      3
    ## 28      AA     19
    ## 29      VX    411
    ## 30      B6    323
    ## 31      B6    324
    ## 32      DL    920
    ## 33      VX    412
    ## 34      DL    464
    ## 35      AA     32
    ## 36      UA   1752
    ## 37      UA    841
    ## 38      AA    117
    ## 39      B6    424
    ## 40      DL    477
    ## 41      VX    416
    ## 42      AA     22
    ## 43      AA    180
    ## 44      B6    423
    ## 45      VX    413
    ## 46      DL    447
    ## 47      AA     21
    ## 48      DL    420
    ## 49      B6    523
    ## 50      UA    535
    ## 51      AA    293
    ## 52      VX    415
    ## 53      B6    623
    ## 54      B6    524
    ## 55      DL   1162
    ## 56      UA    912
    ## 57      DL   1262
    ## 58      VX    420
    ## 59      AA     30
    ## 60      B6    624

``` r
dbDisconnect(con)
```
