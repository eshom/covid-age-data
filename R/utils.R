get_rinfo <- function(data = c("inputDB", "Output_5", "Output_10",
                               "qualityMetrics")) {
        # osf id (for osfr), column classes, and skip lines
        rinfo <- switch(data[1],
                        inputDB        = list("9dsfk",
                                              c("character","character",
                                                "character","character",
                                                "character","character",
                                                "integer",  "character",
                                                "character","numeric",
                                                "character"),
                                              1,
                                              id = "5f3ed659746a8100ad1a2420"),
                        Output_5       = list("7tnfh",
                                              c("character","character",
                                                "character","character",
                                                "character","integer",
                                                "integer",  "numeric",
                                                "numeric",  "numeric"),
                                              3,
                                              id = "5f3ed65ff579150074ea6df0"),
                        Output_10      = list("43ucn",
                                              c("character","character",
                                                "character","character",
                                                "character","integer",
                                                "integer",  "numeric",
                                                "numeric",  "numeric"),
                                              3,
                                              id = "5f3ed666bacde800a533bb10"),
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
                                              1,
                                              id = "5fab07ae6a1ea70029f7f9dd"))

        return(rinfo)
}

coltypes_to_tidy <- function(rinfo) {
        tmp <- substr(rinfo[[2]], 1, 1)
        tmp <- sub("n", "d", tmp, fixed = TRUE) ## n for numeric; d for double
        rinfo[[2]] <- paste(tmp, collapse = "")
        rinfo
}
