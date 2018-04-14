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
#' # This example uses the diamonds dataset in the ggplot2 package to create a
#' # classification model. The goal is to predict whether a diamonds is more or
#' # less than 1 carat
#' library(dplyr)
#' library(ggplot2)
#' # Splitting into a training and test set
#' train_inds <- sample(floor(nrow(diamonds)/2))
#' test_inds <- setdiff(1:nrow(diamonds), train_inds)
#'
#' training_data <- diamonds %>%
#'   slice(train_inds) %>%
#'   mutate(label = (carat > 1))
#'
#' test_data <- diamonds %>%
#' slice(test_inds) %>%
#' mutate(label = (carat > 1))
#' # Training a logistic regression model on the training set.
#' log_model <- glm(label ~ cut + color + clarity + depth + table,
#'     family = binomial(), data = training_data)
#' # Now predict on the test set
#' predictions <- predict(log_model, newdata = test_data, type = "response")
#'
#' # Finally create a gain chart. The gain chart df1 has 10 groups,
#' # with about 2700 observations in each.
#' library(gainr)
#' df1 <- get_gain_chart(actual = test_data$label, predicted = predictions)
#' # If we instead want to focus only on the subject with the highest
#' # predicted probabilities, we might set the groups argument to, say 3000.
#' df2 <- get_gain_chart(actual = test_data$label, predicted = predictions,
#'     groups = 3000)
#'
#' # Using the gains package, we are still able to keep only the topmost
#' # rows of the gain chart. If we want to share the gain chart for the
#' # top-100 rows, we might use the basic functions of dplyr, since `df2`
#' # is a tibble.
#' df_top <- df2 %>% filter(cume.obs <= 100)
get_gain_chart <- function(actual, predicted, ...){
  if(length(actual) != length(predicted)) stop("actual and predicted must have the same length!")

  if(!is.numeric(actual)){
    message("Converting the vector of actuals to numeric")
    actual <- as.numeric(actual)
  }

  gains_obj <- gains::gains(actual = actual, predicted = predicted, ...)

  element_lengths <- sapply(gains_obj, length)
  return(dplyr::as_tibble(gains_obj[element_lengths == max(element_lengths)]))
}
