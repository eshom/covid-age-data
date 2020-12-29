subset_covid <- function(df, Country, Region, Sex, Date) {
        stopifnot(!missing(df))

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
                d <- Date
                df <- collapse::fsubset(df, Date >= d)
        }

        return (df)
}
