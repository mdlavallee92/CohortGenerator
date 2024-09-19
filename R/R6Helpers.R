.setNumeric <- function(private, key, value, nullable = FALSE) {
  checkmate::assert_numeric(x = value, null.ok = nullable)
  private[[key]] <- value
  invisible(private)
}

.setActiveNumeric <- function(private, key, value) {
  # return the value if nothing added
  if(missing(value)) {
    vv <- private[[key]]
    return(vv)
  }
  # replace the codesetTempTable
  .setNumeric(private = private, key = key, value = value)
}
