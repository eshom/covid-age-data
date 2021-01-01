# covidAgeData -- Download and Read COVerAGE-DB Datasets

## Install
To install `covidAgeData` run the following code in your favourite R console:
```r
install.packages("devtools")
devtools::install_github("https://github.com/eshom/covid-age-data")
```

**Note:** The package imports the
[collapse](https://github.com/SebKrantz/collapse/) package,
which is temporarily archived by CRAN. This should be resolved soon.
However, for now run this code to install `covidAgeData`:
```r
install.packages("devtools")
devtools::install_github("https://github.com/SebKrantz/collapse/")
devtools::install_github("https://github.com/eshom/covid-age-data/")
```

## Citation
The package itself can be freely used in any context,
however if you use the data itself, please cite:

COVeAGE-DB: A database of age-structured COVID-19 cases and deaths. Tim Riffe, Enrique Acosta, The COVerAGE-DB team medRxiv 2020.09.18.20197228; doi: <https://doi.org/10.1101/2020.09.18.20197228> Data downloaded from \[DATE\] (<https://doi.org/10.17605/OSF.IO/MPWJQ)[https://doi.org/10.17605/OSF.IO/MPWJQ>]

## See also
The 'COVerAGE-DB' Project page: <https://github.com/timriffe/covid_age>
