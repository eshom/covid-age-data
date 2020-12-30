#' Downloads one of the COVerAGE-DB datasets hosted on [OSF](https://osf.io/mpwjq/).
#' It reads the downloaded data and converts it into a data frame.
#'
#' This function uses the OSF API to download the publicly available COVerAGE-DB
#' datasets. It then returns the downloaded dataset as a data frame, data table, or tibble.
#' There are 4 possible datasets available for download: "inputDB", "Output_5",
#' "Output_10", "qualityMetrics".
#' See <https://timriffe.github.io/covid_age/GettingStarted.html> for more
#' information about these datasets.
#' @seealso [osfr::osf_retrieve()] for the OSF entity retrieval function;
#' [osfr::osf_download()] for the downloading function; [data.table::fread()] for
#' the reading function.
#' @title Download COVerAGE-DB data
#' @param data The name of the dataset to download. Can be one of the
#' the following: "inputDB", "Output_5", "Output_10", "qualityMetrics".
#' @param temp Logical. Should the dataset be downloaded to a temporary directory?
#' @param return What should be the return type? Can be on of the following:
#' "data.frame", "data.table", "tibble".
#' @param progress Passed to [osfr::osf_download()]. Logical, if TRUE
#' progress bars are displayed for each file transfer. Mainly useful for
#' transferring large files. For tracking lots of small files, setting
#' ‘verbose = TRUE’ is more informative.
#' @param conflicts Passed to [osfr::osf_download()]. This determines what
#' happens when a file with the same name
#' exists at the specified destination. Can be one of the
#' following:
#' * ‘"error"’ (the default): throw an error and abort the
#' file transfer operation.
#' * ‘"skip"’: skip the conflicting file(s) and continue
#' transferring the remaining files.
#' * ‘"overwrite"’: replace the existing file with the
#' transferred copy.
#' @param recurse Passed to [osfr::osf_download()]. Applies only to
#' OSF directories. If TRUE, a directory is fully recursed and all nested
#' files and subdirectories are downloaded. Alternatively, a positive number
#' will determine the number of levels to recurse.
#' @param verbose Passed to [osfr::osf_download()] Logical, indicating whether
#' to print informative messages about interactions with the OSF API (default FALSE).
#' @param ... Additional named arguments passed to [data.table::fread()]
#' @return By default a data frame with the uncompressed dataset.
#' Can be set to return either a data table or
#' a tibble. The return type is controlled by the "return" parameter.
#' @author Erez Shomron
#' @examples
#' \dontrun{
#' # Basic usage
#' df <- download_covid("inputDB")
#' # Download data to the working directory.
#' df <- download_covid("Output_5", temp = FALSE)
#' # If you want a tibble instead of a data frame:
#' df <- download_covid("Output_10", return = "tibble")
#' }
#'
#' @export
download_covid <- function(data = c("inputDB", "Output_5", "Output_10",
                                    "qualityMetrics"), temp = TRUE,
                            return = c("data.frame", "data.table", "tibble"),
                            progress = TRUE, conflicts = "overwrite",
                            recurse = FALSE, verbose = FALSE, ...) {
        stopifnot(is.character(data))

        # osf id (for osfr), column classes, and skip lines
        rinfo <- switch(data[1],
                        inputDB        = list("9dsfk",
                                              c("character","character",
                                                "character","character",
                                                "character","character",
                                                "integer",  "character",
                                                "character","character",
                                                "numeric",  "character"),
                                              1),
                        Output_5       = list("7tnfh",
                                              c("character","character",
                                                "character","character",
                                                "character","integer",
                                                "integer",  "numeric",
                                                "numeric",  "numeric"),
                                              3),
                        Output_10      = list("43ucn",
                                              c("character","character",
                                                "character","character",
                                                "character","integer",
                                                "integer",  "numeric",
                                                "numeric",  "numeric"),
                                              3),
                        qualityMetrics = list("qpfw5",
                                              c("character","character",
                                                "Date",     "character",
                                                "numeric",  "numeric",
                                                "numeric",  "character",
                                                "character","integer",
                                                "integer",  "integer",
                                                "integer",  "integer",
                                                "integer",  "logical",
                                                "numeric",  "numeric"),
                                              1))
        stopifnot(!is.null(rinfo)) # means 'data' wasn't one of the listed datasets

        stopifnot(is.logical(temp))
        if (temp) {
                path <- tempdir() # cleaned up after reading the dataset
        } else {
                path <- getwd()
        }

        osf <- osfr::osf_retrieve_file(rinfo[[1]])
        osfr::osf_download(osf, path, progress = progress,
                           conflicts = conflicts, recurse = recurse,
                           verbose = verbose)

        filename    <- paste0(data[1], ".zip")
        zippath     <- file.path(path, filename)
        archivefile <- file.path("Data", paste0(data[1], ".csv"))

        stopifnot(file.exists(zippath)) # The file was not downloaded or deleted
        if (temp) on.exit(unlink(zippath), add = TRUE) # Cleanup

        filepath <- unzip(zippath, archivefile, exdir = tempdir())
        on.exit(unlink(filepath), add = TRUE) # Cleanup

        message("Reading ", filepath)
        out <- data.table::fread(filepath, sep = ',',
                                 colClasses = rinfo[[2]], skip = rinfo[[3]], ...)

        return <- return[1]
        switch(return,
               data.frame = return (collapse::qDF(out)),
               data.table = return (out),
               tibble     = return (collapse::qTBL(out)))

        warning("Invalid return type specified, returning data.frame")
        return (collapse::qDF(out))
}
