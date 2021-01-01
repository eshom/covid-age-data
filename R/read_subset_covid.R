#' Reads a subset of a locally saved COVerAGE-DB dataset.
#' Data manipulation is handled almost completely out-of-memory,
#' at the cost of speed.
#'
#' The function uses \pkg{ff} as backend for manipulating the dataset
#' out-of-memory. Read and write operations on a drive are slower compared
#' to running these operations on random-access memory (RAM). Nevertheless,
#' it is advantageous to operate out-of-memory to be able to work with very
#' large datasets, or to generally conserve memory the *R* process uses.
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
#' character vector, then the date must be in "yyyy-mm-dd" format.
#' @return By default a data frame with the subsetted dataset.
#' Can be set to return either a data table or
#' a tibble. The return type is controlled by the 'return' parameter.
#' @author Erez Shomron
#'
#' @export
read_subset_covid <- function(zippath,
                              data = c("inputDB", "Output_5", "Output_10",
                                       "qualityMetrics"),
                              return = c("data.frame", "data.table",
                                         "tibble"),
                              Country, Region, Sex, Date) {
        stopifnot(is.character(data), is.character(zippath),
                  length(zippath) == 1)
        rinfo <- get_rinfo(data[1])
        stopifnot(!is.null(rinfo))

        miss_args    <- c(Country = missing(Country),
                          Region  = missing(Region),
                          Sex     = missing(Sex),
                          Date    = missing(Date))
        # If there isn't any subset arguments, then stop here.
        # Otherwise the returned dataset may take up too much memory,
        # and the point of this function is too subset to reduce memory usage.
        if (all(miss_args)) {
                stop("No subsetting arguments were passed. ",
                     "Out of memory subsetting is not required.")
        }

        # 'ffdf' objects support factors, but not character vectors.
        # We will read characters as factors, and after subsetting,
        # we will convert back factor columns to character columns.
        rinfo[[2]] <- ifelse(rinfo[[2]] == "character", "factor", rinfo[[2]])

        archivefile <- file.path("Data", paste0(data[1], ".csv"))
        zcon <- unz(zippath, archivefile)
        df   <- ff::read.csv.ffdf(file = zcon, colClasses = rinfo[[2]],
                                  skip = rinfo[[3]])

        # This object needs to be in the search path, otherwise
        # 'ffbase::subset.ffdf()' may throw an error because it
        # assumes ff is attached.
        .rambytes <- ff::.rambytes

        date_is_date <- inherits(df$Date, "Date")

        if (!miss_args["Country"]) {
                c  <- Country
                df <- ffbase::subset.ffdf(df, Country %in% c)
        }
        # No reason to continue if we have 0 rows
        if(nrow(df) == 0) return (as.data.frame(df))
        if (!miss_args["Region"]) {
                r  <- Region
                df <- ffbase::subset.ffdf(df, Region %in% r)
        }
        if(nrow(df) == 0) return (as.data.frame(df))
        if (!miss_args["Sex"]) {
                s  <- Sex
                df <- ffbase::subset.ffdf(df, Sex %in% s)
        }
        if(nrow(df) == 0) return (as.data.frame(df))
        if (!miss_args["Date"]) {
                if (!inherits(Date, "Date")) {
                        # default expected format: yyyy-mm-dd
                        Date <- as.Date(Date)
                }
                if (!date_is_date) {
                        df <-ffbase::transform.ffdf(df, Date = as.Date(Date, "%d.%m.%Y"))
                }
                d  <- min(Date)
                df <- ffbase::subset.ffdf(df, Date >= d)
        }
        if(nrow(df) == 0) return (as.data.frame(df))

        out <- as.data.frame(df)

        # Convert factor columns back to character columns
        out <- collapse::ftransformv(out, is.factor, as.character)

        # if df$Date wasn't a Date object, and it was transformed,
        # then convert back.
        if (!miss_args["Date"] && !date_is_date) {
                out <- collapse::ftransform(out, Date = format(Date, "%d.%m.%Y"))
        }

        return <- return[1]
        switch(return,
               data.frame = return (out),
               data.table = return (collapse::qDT(out)),
               tibble     = return (collapse::qTBL(out)))

        warning("Invalid return type specified, returning data.frame")
        return(out)
}
