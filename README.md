# covidAgeData: Download and Read COVerAGE-DB Datasets

## Install
To install `covidAgeData` run the following code in your favourite R console:
```r
install.packages("remotes")
remotes::install_github("https://github.com/eshom/covid-age-data")
```

## Getting started
You can download and read the newest versions of data in one command:
```r
library(covidAgeData)
df <- download_covid(data = "Output_10")
head(df)
```
```
Downloading Output_10.zip
  |======================================================================| 100%
Reading /tmp/RtmpuvKg50/Data/Output_10.csv
      Country Region         Code       Date Sex Age AgeInt Cases Deaths Tests
1 Afghanistan    All AF01.07.2020 01.07.2020   b   0     10   169      0    NA
2 Afghanistan    All AF01.07.2020 01.07.2020   b  10     10  1525      5    NA
3 Afghanistan    All AF01.07.2020 01.07.2020   b  20     10  7948     18    NA
4 Afghanistan    All AF01.07.2020 01.07.2020   b  30     10  7592     54    NA
5 Afghanistan    All AF01.07.2020 01.07.2020   b  40     10  5362    117    NA
6 Afghanistan    All AF01.07.2020 01.07.2020   b  50     10  3747    161    NA
```

By default `download_covid()` saves the downloaded dataset in the current
working directory, so it can be read again later:
```r
df <- read_covid(zippath = "Output_10.zip", data = "Output_10")
```

Downloading [specific versions of COVerAge-DB datasets](https://osf.io/9dsfk/?show=revision) is possible:
```r
download_covid_version(data = "inputDB", version = 1, return = "tibble")
```
```
Downloading inputDB_v1.zip (timeout set to 60)
trying URL 'https://osf.io/9dsfk/download?version=1'
Content type 'application/octet-stream' length 10287585 bytes (9.8 MB)
==================================================
downloaded 9.8 MB

Reading /tmp/RtmpuvKg50/Data/inputDB.csv
# A tibble: 2,494,617 x 11
   Country   Region Code    Date   Sex   Age   AgeInt Metric Measure Value Short
   <chr>     <chr>  <chr>   <chr>  <chr> <chr>  <int> <chr>  <chr>   <dbl> <chr>
 1 Afghanis… All    AF01.0… 01.07… b     0         10 Count  Cases     169 AF
 2 Afghanis… All    AF01.0… 01.07… b     10        10 Count  Cases    1525 AF
 3 Afghanis… All    AF01.0… 01.07… b     20        10 Count  Cases    7948 AF
 4 Afghanis… All    AF01.0… 01.07… b     30        10 Count  Cases    7592 AF
 5 Afghanis… All    AF01.0… 01.07… b     40        10 Count  Cases    5362 AF
 6 Afghanis… All    AF01.0… 01.07… b     50        10 Count  Cases    3747 AF
 7 Afghanis… All    AF01.0… 01.07… b     60        10 Count  Cases    2267 AF
 8 Afghanis… All    AF01.0… 01.07… b     70        10 Count  Cases     840 AF
 9 Afghanis… All    AF01.0… 01.07… b     80        25 Count  Cases     301 AF
10 Afghanis… All    AF01.0… 01.07… b     TOT       NA Count  Cases   29751 AF
# … with 2,494,607 more rows
```

For very large data, it may be advantageous to subset it before completely reading it to memory. This is done with `read_subset_covid()`:
```r
download_covid(data = "inputDB", download_only = TRUE)
df <- read_subset_covid("inputDB.zip", data = "inputDB", return = "tibble",
                        Country = "USA",
                        Region = "New York City",
                        Sex = "f",
                        Date = "01.10.2020")
df
```
```
Downloading inputDB.zip
  |======================================================================| 100%
# A tibble: 12 x 11
   Country Region   Code     Date  Sex   Age   AgeInt Metric Measure Value Short
   <chr>   <chr>    <chr>    <chr> <chr> <chr>  <int> <chr>  <chr>   <dbl> <chr>
 1 USA     New Yor… US_CDC_… 28.1… f     0          1 Count  Deaths      1 US_C…
 2 USA     New Yor… US_CDC_… 28.1… f     1          4 Count  Deaths      1 US_C…
 3 USA     New Yor… US_CDC_… 28.1… f     5         10 Count  Deaths      2 US_C…
 4 USA     New Yor… US_CDC_… 28.1… f     15        10 Count  Deaths     10 US_C…
 5 USA     New Yor… US_CDC_… 28.1… f     25        10 Count  Deaths     59 US_C…
 6 USA     New Yor… US_CDC_… 28.1… f     35        10 Count  Deaths    119 US_C…
 7 USA     New Yor… US_CDC_… 28.1… f     45        10 Count  Deaths    401 US_C…
 8 USA     New Yor… US_CDC_… 28.1… f     55        10 Count  Deaths   1072 US_C…
 9 USA     New Yor… US_CDC_… 28.1… f     65        10 Count  Deaths   1800 US_C…
10 USA     New Yor… US_CDC_… 28.1… f     75        10 Count  Deaths   2341 US_C…
11 USA     New Yor… US_CDC_… 28.1… f     85        20 Count  Deaths   2811 US_C…
12 USA     New Yor… US_CDC_… 28.1… f     TOT       NA Count  Deaths   8617 US_C…
```

If memory efficiency is not an issue, `subset_covid()` is the in-memory version:
```r
df <- read_covid("Output_10.zip", "Output_10", return = "tibble")
subset_covid(df, Country = "Sweden")
```
```
Reading /tmp/Rtmptv6DoX/Data/Output_10.csv
# A tibble: 2,255 x 10
   Country Region Code           Date     Sex     Age AgeInt  Cases Deaths Tests
   <chr>   <chr>  <chr>          <chr>    <chr> <int>  <int>  <dbl>  <dbl> <dbl>
 1 Sweden  All    SE_ECDC_01.11… 01.11.2… b         0     10  1046     10     NA
 2 Sweden  All    SE_ECDC_01.11… 01.11.2… b        10     10  8818      0     NA
 3 Sweden  All    SE_ECDC_01.11… 01.11.2… b        20     10 24930     10     NA
 4 Sweden  All    SE_ECDC_01.11… 01.11.2… b        30     10 21989     17     NA
 5 Sweden  All    SE_ECDC_01.11… 01.11.2… b        40     10 22242     46     NA
 6 Sweden  All    SE_ECDC_01.11… 01.11.2… b        50     10 22537    165     NA
 7 Sweden  All    SE_ECDC_01.11… 01.11.2… b        60     10 12418    414     NA
 8 Sweden  All    SE_ECDC_01.11… 01.11.2… b        70     10  7519   1279     NA
 9 Sweden  All    SE_ECDC_01.11… 01.11.2… b        80     10  6164.  2092.    NA
10 Sweden  All    SE_ECDC_01.11… 01.11.2… b        90     10  4914.  1794.    NA
# … with 2,245 more rows
```

For repeated read and subset operations, it's recommended to cache the output.
One way to do so is with [memoise](http://memoise.r-lib.org):
```r
library(memoise)
mem_read_subset_covid <- memoise(read_subset_covid)
microbenchmark::microbenchmark(no_cache = read_subset_covid("inputDB.zip",
                                                            "inputDB",
                                                            Country = "Brazil"),
                               cache = mem_read_subset_covid("inputDB.zip",
                                                             "inputDB",
                                                             Country = "Brazil"),
                               times = 10)
```
```
Unit: microseconds
     expr         min          lq       mean       median           uq      max
 no_cache 7015553.357 7383738.955 18515155.4 8034852.2075 20785961.351 64893443
    cache     593.748     621.755   734404.8     672.4395      804.345  7337885
 neval
    10
    10
```

## Citation
The package itself can be freely used in any context,
however if you use the data itself please cite:

Tim Riffe, Enrique Acosta, the COVerAGE-DB team, Data Resource Profile: COVerAGE-DB: a global demographic database of COVID-19 cases and deaths, International Journal of Epidemiology, Volume 50, Issue 2, April 2021, Pages 390–390f, https://doi.org/10.1093/ije/dyab027 Data downloaded from \[DATE\] (<https://doi.org/10.17605/OSF.IO/MPWJQ)[https://doi.org/10.17605/OSF.IO/MPWJQ>]

## See also
The 'COVerAGE-DB' Project page: <https://github.com/timriffe/covid_age>
