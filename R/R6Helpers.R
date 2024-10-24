.setInteger <- function(private, key, value, nullable = FALSE) {
  checkmate::assert_integer(x = value, null.ok = nullable)
  private[[key]] <- value
  invisible(private)
}

.setActiveInteger <- function(private, key, value) {
  # return the value if nothing added
  if(missing(value)) {
    vv <- private[[key]]
    return(vv)
  }
  .setInteger(private = private, key = key, value = value)
}
