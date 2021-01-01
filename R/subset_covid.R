#' Subset any of the COVerAGE-DB datasets that is already read into memory.
#'
#' This function assumes the 'df' argument is one of the COVerAGE-DB datasets,
#' or at least has a similar format. There's no check to test if this input is
#' correct. Missing arguments except 'df' are ignored.
#' The 'Date' argument can be either
#' a character vector of a date, which will be converted to a 'Date' object,
#' or alternatively a 'Date' object, which conversion will be skipped for.
#' Dates are subsetted so the included dates are from the date inputted to the
#' most recent date in the dataset. If multiple dates are passed, only the
#' earliest date is taken into account.
#' Countries that do not have regional data only have "All" set as their region.
#' Subsetting is very fast due to the usage of the \pkg{collapse} package
#' as a backend.
#' @title Subset COVerAGE-DB Datasets
#' @param df `data.frame`, `data.table`, or `tbl_df`.
#' Expecting a COVerAGE-DB dataset.
#' @param Country Character vector of countries to select.
#' @param Region Character vector of regions to select.
#' @param Sex Character vector of sexes to select. Usually either 'b' for both.
#' 'f' for females, and 'm' for males.
#' @param Date Either a character or Date vector of dates to include. If a
#' character vector, then the date must be in "yyyy-mm-dd" format.
#' @return The subsetted data frame like object.
#' @author Erez Shomron
#' @examples
#' \dontrun{
#' # Nothing happens
#' subset_covid(df)
#' # Select several countries
#' subset_covid(df, Country = c("USA", "Sweden"))
#' # Sweden, females only
#' subset_covid(df, Country = "Sweden", Sex = "f")
#' # New York City
#' subset_covid(df, Country = "USA", Region = "New York City")
#' subset_covid(df, Region = "New York City")
#' # All countries since "2020-12-01"
#' subset_covid(df, Date = as.Date("2020-12-01"))
#' subset_covid(df, Date = "2020-12-01")
#' }
#'
#' @export
subset_covid <- function(df, Country, Region, Sex, Date) {
        stopifnot(!missing(df))

        date_is_date <- inherits(df$Date, "Date")

        if (!missing(Country)) {
                c <- Country
                df <- collapse::fsubset(df, Country %in% c)
        }
        if (!missing(Region)) {
                r <- Region
                df <- collapse::fsubset(df, Region %in% r)
        }
        if (!missing(Sex)) {
                s <- Sex
                df <- collapse::fsubset(df, Sex %in% s)
        }
        if (!missing(Date)) {
                stopifnot(inherits(Date, "Date"))
                if (!date_is_date) {
                        df <- collapse::ftransform(df, Date = as.Date(Date, "%d.%m.%Y"))
                }
                d  <- min(Date)
                df <- collapse::fsubset(df, Date >= d)
        }

        # if df$Date wasn't a Date object, and it was transformed,
        # then convert back.
        if (!missing(Date) && !date_is_date) {
                df <- collapse::ftransform(df, Date = format(Date, "%d.%m.%Y"))
        }

        return (df)
}
