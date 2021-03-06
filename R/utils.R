#
# Convert from IB timestamp string to POSIXct
#
# There are two cases:
# "yyyymmdd-hh:mm:ss"      UTC
# "yyyymmdd hh:mm:ss ttzz"  local in timezone "ttzz"
#
from_IBtime <- function(s)
{

  res <- if(nchar(s) == 17L)
           as.POSIXct(s, format("%Y%m%d-%T"), tz=checkTZ("UTC"))

         else if(nchar(s) >= 21L)
           as.POSIXct(s, format("%Y%m%d %T"), tz=checkTZ(substr(s, 19L, nchar(s))))

  stopifnot(!is.null(res),
            !is.na(res))

  res
}


#
# Convert to IB timestamp string "yyyymmdd hh:mm:ss ttz"
#
# ttz understood by IB: UTC GMT EDT EST CET CEST BST and GMT+-hh:mm
#
to_IBtime <- function(p, tz="UTC")
{
  stopifnot(inherits(p, "POSIXct"))

  format(p, format="%Y%m%d %T %Z", tz=checkTZ(tz))
}

#
# Check, and possibly override, the timezone to make sure
# it's valid.
#
# !!! POSIXct functions silently ignore invalid timezones
#
checkTZ <- function(tz)
{
  if(tz %in% c("EDT", "EST", "Eastern Standard Time"))
    tz <- "America/New_York"

  else if(tz %in% c("CEST", "CET"))
    tz <- "Europe/Paris"

  else if(tz %in% c("BST", "British Summer Time", "Greenwich Mean Time"))
    tz <- "Europe/London"

  # Make sure it's recognized by R functions
  stopifnot(tz %in% OlsonNames())

  tz
}

#
# Attach an iterator to a vector
#
make_iter <- function(v)
{

  pos <- 0L

  list(pop= function(n=1L) {

              filter <- pos + seq_len(n)

              if(length(filter) > 0L) {

                stopifnot( (new_pos <- filter[n]) <= length(v))

                pos <<- new_pos
              }

              v[filter]
            },
       left= function() length(v) - pos
      )
}
