#' Get a Gain Chart
#'
#' @param actual a vector containing the true labels
#' @param predicted numeric vector of predicted labels
#' @param ... other arguments passed to method gains::gains
#'
#' @return A tibble containing the gain chart.
#' @export
#'
#' @examples
get_gain_chart <- function(actual, predicted, ...){
  if(!is.numeric(actual)){
    message("Converting the vector of actuals to numeric")
    actual <- as.numeric(actual)
  }

  gains_obj <- gains::gains(actual = actual, predicted = predicted, ...)

  element_lengths <- sapply(gains_obj, length)
  return(dplyr::as_tibble(gains_obj[element_lengths == max(element_lengths)]))
}
