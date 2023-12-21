#' Make an API Request to Stripe
#'
#' This function makes a GET request to a specified Stripe API endpoint using provided query parameters and authentication details. 
#' It is a helper function to interact with the Stripe API.
#'
#' @param endpoint A string specifying the API endpoint to be accessed.
#' @param query_list A list of query parameters to be included in the request.
#' @param secret_key A string representing the Stripe secret key for authentication.
#' @param api_base_url A string specifying the base URL of the Stripe API. Default is 'https://api.stripe.com/v1'.
#'
#' @return A response object from the Stripe API, or NULL in case of an error.
#'
#' @examples
#' \dontrun{
#'   response <- make_api_request("/customers",
#'                               list(email = "customer@example.com"),
#'                               "your_secret_key")
#' }
#'
#' @importFrom httr GET content authenticate
#' @export
make_api_request <-
  function(endpoint,
           query_list,
           secret_key,
           api_base_url = 'https://api.stripe.com/v1') {
    response <- tryCatch({
      httr::content(httr::GET(
        url = paste0(api_base_url, endpoint),
        query = query_list,
        authenticate(user = secret_key, password = '')
      ))
    }, error = function(e) {
      NULL  # Handle error appropriately
    })
    return(response)
  }

#' Retrieve and Format Stripe Plans Data
#'
#' This function fetches plans data from Stripe using the `make_api_request` helper function and formats it into a data frame. 
#' It provides a structured view of the plans available in Stripe.
#'
#' @param secret_key A string representing the Stripe secret key for authentication.
#'
#' @return A data frame containing Stripe plans data. 
#' Each row represents a plan with fields like amount, currency, price_id, product_id, and period. 
#' Returns NULL if no data is found or in case of an error.
#'
#' @examples
#' \dontrun{
#'   plans <- plans_table("your_secret_key")
#'   print(plans)
#' }
#'
#' @importFrom dplyr %>%
#' @export
plans_table <- function(secret_key) {
  plans_response <- make_api_request('/plans', list(), secret_key)
  
  # Check if the API response is valid and contains data
  if (is.null(plans_response) || length(plans_response$data) == 0) {
    message('Plans data not found or an error occurred during the API request.')
    return(NULL)
  }
  
  # Processing and formatting the data
  plans_data <- plans_response$data
  table <- lapply(plans_data, function(plan) {
    row <- c(
      amount = plan$amount,
      currency = plan$currency,
      price_id = plan$id,
      product_id = plan$product,
      period = paste(plan$interval_count, plan$interval)
    )
    return(row)
  }) %>%
    do.call(rbind, .) %>%
    data.frame(stringsAsFactors = FALSE)
  
  return(table)
}

#' Retrieve Customer and Subscription Data from Stripe
#'
#' This function fetches customer data based on the email provided and retrieves associated subscription data using the Stripe API.
#'
#' @param email A string representing the customer's email.
#' @param secret_key A string representing the Stripe secret key for authentication.
#'
#' @return A list containing two elements: `res_sub` (subscription data) and `res_cus` (customer data). 
#' Returns NULL if no data is found or in case of an error.
#'
#' @examples
#' \dontrun{
#'   user_data <- get_user("customer@example.com", "your_secret_key")
#'   print(user_data)
#' }
#'
#' @export
get_user <- function(email, secret_key) {
  # Retrieve customer data
  res_cus <-
    make_api_request('/customers', list(email = email), secret_key)
  if (is.null(res_cus) || length(res_cus$data) == 0) {
    return(NULL)  # Or handle error appropriately
  }
  customer_id <- res_cus$data[[1]]$id
  
  # Retrieve subscription data
  res_sub <-
    make_api_request('/subscriptions', list(customer = customer_id), secret_key)
  if (is.null(res_sub)) {
    return(NULL)  # Or handle error appropriately
  }
  
  return(list('res_sub' = res_sub, 'res_cus' = res_cus))
}

#' Check Customer's Subscription Status
#'
#' This function checks whether a given customer, identified by their email, has any active subscription in Stripe.
#'
#' @param email A string representing the customer's email.
#' @param secret_key A string representing the Stripe secret key for authentication.
#'
#' @return A logical value: TRUE if the customer has an active subscription, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#'   subscription_status <- has_plan("customer@example.com", "your_secret_key")
#'   print(subscription_status)
#' }
#'
#' @export
has_plan <- function(email, secret_key) {
  user_data <- get_user(email, secret_key)
  if (is.null(user_data) || length(user_data$res_sub$data) == 0) {
    return(FALSE)
  }
  return(TRUE)
}

#' Check if Customer is Subscribed to a Specific Product
#'
#' This function determines whether a customer, identified by their email, is subscribed to a specific product in Stripe.
#'
#' @param email A string representing the customer's email.
#' @param secret_key A string representing the Stripe secret key for authentication.
#' @param product_id A string representing the product ID to check against the customer's subscription.
#'
#' @return A logical value: TRUE if the customer is subscribed to the specified product, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#'   is_subscribed_to_product <- has_plan_product("customer@example.com", "your_secret_key", "prod_example")
#'   print(is_subscribed_to_product)
#' }
#'
#' @export
has_plan_product <- function(email, secret_key, product_id) {
  user_data <- get_user(email, secret_key)
  if (is.null(user_data) || length(user_data$res_sub$data) == 0) {
    return(FALSE)
  }
  user_product_id <- user_data$res_sub$data[[1]]$plan$product
  return(product_id == user_product_id)
}


#' Check if Customer is Subscribed with a Specific Price ID
#'
#' This function checks whether a customer, identified by their email, is subscribed with a specific price ID in Stripe.
#'
#' @param email A string representing the customer's email.
#' @param secret_key A string representing the Stripe secret key for authentication.
#' @param price_id A string representing the price ID to check against the customer's subscription.
#'
#' @return A logical value: TRUE if the customer is subscribed with the specified price ID, FALSE otherwise.
#'
#' @examples
#' \dontrun{
#'   is_subscribed_to_price <- has_plan_price("customer@example.com", "your_secret_key", "price_example")
#'   print(is_subscribed_to_price)
#' }
#'
#' @export
has_plan_price <- function(email, secret_key, price_id) {
  user_data <- get_user(email, secret_key)
  if (is.null(user_data) || length(user_data$res_sub$data) == 0) {
    return(FALSE)
  }
  user_price_id <- user_data$res_sub$data[[1]]$plan$id
  return(price_id == user_price_id)
}