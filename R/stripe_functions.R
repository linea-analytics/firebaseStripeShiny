#' Get All Plans from Stripe API
#'
#' This function retrieves all the plans from the Stripe API.
#' It requires a secret key for authentication.
#'
#' @param secret_key A string containing the secret key for Stripe API authentication.
#'
#' @return An object of class `response` representing the API response.
#' @export
get_all_plans = function(secret_key) {
  res = GET(url = 'https://api.stripe.com/v1/plans',
            authenticate(user = secret_key,
                         password = ''))
  
  return(res)
}

#' Retrieve and Format Plans Data from Stripe API
#'
#' This function fetches all plans from the Stripe API using the `get_all_plans` function
#' and formats the data into a tabular structure. It requires a secret key for authentication.
#' If no data is found, it displays an error message from the API response.
#'
#' @param secret_key A string containing the secret key for Stripe API authentication.
#'
#' @return A data frame containing the plans data with columns: amount, currency, and period.
#'         If no plans data is found, an informative message is displayed.
#' @importFrom dplyr %>%
#' @importFrom httr content
#' @export
plans_table = function(secret_key) {
  plans = get_all_plans(secret_key)
  plans_data = content(plans)$data
  
  if (is.null(plans_data)) {
    message('Plans data not found. Stripe API response message:',
            content(plans)$error$message)
  } else{
    table = lapply(plans_data, function(plan) {
      row = c(
        amount = plan$amount,
        currency = plan$currency,
        period = paste(plan$interval_count, plan$interval)
      )
      
      return(row)
      
    }) %>%
      Reduce(f = rbind) %>%
      data.frame(row.names = NULL)
    
    return(table)
    
  }
}

#' Retrieve Customer Data by Email from Stripe API
#'
#' This function fetches customer data from the Stripe API based on the provided email address.
#' It requires an email address and a secret key for authentication.
#'
#' @param email The email address of the customer to be retrieved.
#' @param secret_key A string containing the secret key for Stripe API authentication.
#'
#' @return An object of class `response` representing the API response, which contains
#'         the customer data if found, or an error message otherwise.
#' @importFrom httr GET
#' @export
get_customer_by_email = function(email, secret_key) {
  res = GET(
    url = 'https://api.stripe.com/v1/customers',
    query = list(email = email),
    authenticate(user = secret_key,
                 password = '')
  )
  
  return(res)
}

#' Retrieve Customer Subscription Information by ID from Stripe API
#'
#' This function fetches subscription information for a specific customer from the Stripe API.
#' It requires a customer ID and a secret key for authentication.
#'
#' @param secret_key A string containing the secret key for Stripe API authentication.
#' @param customer_id The unique identifier of the customer whose subscription information is to be retrieved.
#'
#' @return An object of class `response` representing the API response, which contains
#'         the subscription information for the given customer ID.
#' @importFrom httr GET
#' @export
get_customer_sub_by_id = function(secret_key, customer_id) { #get subscription information by customer id
  res_sub = GET(
    url = 'https://api.stripe.com/v1/subscriptions',
    query = list(customer = customer_id),
    authenticate(user = secret_key,
                 password = '')
  )
  return(res_sub)
}

#' Check if User Has an Active or Trialing Plan Based on Email
#'
#' This function checks if a user, identified by their email, has an active or trialing
#' subscription plan in Stripe. It first retrieves the customer's ID based on their email,
#' then fetches their subscription details to determine the status and product of the subscription.
#'
#' @param email The email address of the user.
#' @param secret_key A string containing the secret key for Stripe API authentication.
#'
#' @return A list containing a boolean field `has_plan` indicating whether the user has an
#'         active or trialing plan, and `content_sub_prod` which is the product associated
#'         with the subscription. Returns `FALSE` if the user does not have an active or
#'         trialing plan, or if the customer ID is not found.
#' @importFrom httr content
#' @export
user_has_plan_prod = function(email, secret_key) {
  
  res_cust = get_customer_by_email(email, secret_key)
  customer_id <- NA
  tryCatch({
    customer_id <- content(res_cust)$data[[1]]$id
  }, error = function(e) {
    # customer_id remains NA
  })
  if (is.na(customer_id)) {
    return(FALSE)
  } else {
    res_sub = get_customer_sub_by_id(customer_id, secret_key)
    #get status of subscription
    content_sub_st <- content(res_sub)$data[[1]]$status 
    #get product of subscription - used to hide certain parts in your app (this can also be price id if there is 1 product: content(res_sub)$data[[1]]$price$id, see https://stripe.com/docs/api/subscriptions/object)
    content_sub_prod <-content(res_sub)$data[[1]]$plan$product 
    #filter on status plus return product to use in your app
    if (content_sub_st == "active" || content_sub_st == "trialing") {
      return(list(has_plan = TRUE, content_sub_prod = content_sub_prod))
    } else {
      return(FALSE)
    }
  }
}