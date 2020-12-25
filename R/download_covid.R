#' Downloads one of the COVerAGE-DB datasets hosted on [OSF](https://osf.io/mpwjq/).
#' It reads the downloaded data and converts it into a data frame.
#'
#' This function uses the OSF API to download the publicly available COVerAGE-DB
#' datasets. It then returns the downloaded dataset as a data frame or tibble.
#' There are 4 possible datasets available for download: "inputDB", "output_5",
#' "output_10", "qualityMetrics".
#' See <https://timriffe.github.io/covid_age/GettingStarted.html> for more
#' information about these datasets and the reading routine
#' used in this function.
#' @seealso [osfr::osf_retrieve()] for the OSF entity retrieval function;
#' [osfr::osf_download()] for the downloading function; [readr::read_csv()] for
#' the reading function.
#' @title Download COVerAGE-DB data
#' @param data The name of the dataset to download. Can be one of the
#' the following: "inputDB", "output_5", "output_10", "qualityMetrics".
#' @param temp Logical. Should the dataset be downloaded to a temporary directory?
#' @param tibble Logical. should the function return a tibble?
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
#' @param ... Additional named arguments passed to [readr::read_csv()]
#' @return By default a data frame or a tibble. The return value is controlled
#' by the "tibble" parameter.
#' @author Erez Shomron
#' @examples
#' \dontrun{
#' # Basic usage
#' df <- download_covid("inputDB")
#' # Download data to the working directory.
#' df <- download_covid("output_5", temp = FALSE)
#' # If you want a tibble instead of a data frame:
#' df <- download_covid("output_10", tibble = TRUE)
#' }
#'
#' @export
download_covid <- function(data = c("inputDB", "output_5", "output_10",
                                    "qualityMetrics"), temp = TRUE,
                           tibble = FALSE, progress = TRUE,
                           conflicts = "overwrite", recurse = FALSE,
                           verbose = FALSE, ...) {
        # osf id (for osfr), column types (for readr), and skip lines
        rinfo <- switch(data[1],
                        inputDB        = list("9dsfk", "cccccciccdc", 1),
                        output_5       = list("7tnfh", "ccccciiddd", 3),
                        output_10      = list("43ucn", "ccccciiddd", 3),
                        qualityMetrics = list("qpfw5", "ccDcdddcciiiiiildd", 1))
        if (temp) {
                path <- tempdir() # cleaned up after reading the dataset
        } else {
                path <- getwd()
        }
        osf <- osfr::osf_retrieve_file(rinfo[[1]])
        osfr::osf_download(osf, path, progress = progress,
                           conflicts = conflicts, recurse = recurse,
                           verbose = verbose)

        filepath <- file.path(path, paste0(data[1], ".zip"))

        out <- readr::read_csv(filepath, col_types = rinfo[[2]],
                               skip = rinfo[[3]], ...)
        if (temp) {
                unlink(filepath) # temporary file cleanup
                if (tibble) return (out)
                return (as.data.frame(out))
        } else {
                if (tibble) return (out)
                return (as.data.frame(out))
        }
}
