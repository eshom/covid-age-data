#' Lazily reads a subset of a locally saved COVerAGE-DB dataset.
#' Data manipulation is handled lazily.
#'
#' The function uses \pkg{vroom} as backend for reading the dataset
#' lazily. The result of this is a memory efficient processing of the data.
#' This approach tends to be slower than reading the whole dataset in memory.
#' Nevertheless, the cost in speed is advantageous to be able to work with
#' very large datasets, or to generally conserve memory the *R* process uses.
#' Specifically, this is useful for reading the 'inputDB' dataset,
#' which currently holds millions of rows.
#' @title Read a subset of a COVerAGE-DB dataset
#' @param zippath Character. The local zip archive of the downloaded dataset.
#' @param data The name of the dataset that is to be read. Can be one of the
#' the following: "inputDB", "Output_5", "Output_10", "qualityMetrics".
#' @param return What should be the return type? Can be on of the following:
#' "data.frame", "data.table", "tibble".
#' @param Country Character vector of countries to select.
#' @param Region Character vector of regions to select.
#' @param Sex Character vector of sexes to select. Usually either 'b' for both.
#' 'f' for females, and 'm' for males.
#' @param Date Either a character or Date vector of dates to include. If a
#' character vector.
#' @return By default a data frame with the subsetted dataset.
#' Can be set to return either a data table or
#' a tibble. The return type is controlled by the 'return' parameter.
#'
#' @author Erez Shomron
#' @export
read_subset_covid <- function(zippath,
                              data = c("inputDB", "Output_5", "Output_10",
                                       "qualityMetrics"),
                              return = c("data.frame", "data.table",
                                         "tibble"),
                              Country, Region, Sex, Date) {
        stopifnot(is.character(data), is.character(zippath),
                length(zippath) == 1)
        rinfo <- coltypes_to_tidy(get_rinfo(data[1]))

        df <- vroom::vroom(zippath, ",", col_types = rinfo[[2]],
                           skip = rinfo[[3]])

        date_is_date <- inherits(df$Date, "Date")

        if (!missing(Country)) {
                df <- df[df$Country %in% Country, ]
        }
        if (!missing(Region)) {
                df <- Region[df$Region %in% Region, ]
        }
        if (!missing(Sex)) {
                df <- df[df$Sex %in% Sex, ]
        }
        if (!missing(Date)) {
                if (!inherits(Date, "Date")) {
                        Date <- as.Date(Date,
                                        tryFormats = c("%Y-%m-%d", "%Y/%m/%d",
                                                       "%d.%m.%Y", "%d/%m/%Y",
                                                       "%m.%d.%Y", "%m/%d/%Y"))
                }
                if (!date_is_date) {
                        df$Date <- as.Date(df$Date, "%d.%m.%Y")
                }
                d  <- min(Date)
                df <- df[df$Date >= d, ]
        }

        # if df$Date wasn't a Date object, and it was transformed,
        # then convert back.
        if (!missing(Date) && !date_is_date) {
                df$Date <- format(df$Date, "%d.%m.%Y")
        }

        ## Coercing the data using collapse might return an object
        ## That is completely in memory. This is intentional. After subsetting
        ## the memory usage should be considerably less expensive.
        return <- return[1]
        switch(return,
                data.frame = return(collapse::qDF(df)),
                data.table = return(collapse::qDT(df)),
                tibble = return(collapse::qTBL(df)))

        warning("Invalid return type specified, returning data.frame")
        return(collapse::qDF(df))
}
