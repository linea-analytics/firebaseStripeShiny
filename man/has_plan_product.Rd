% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stripe_functions.R
\name{has_plan_product}
\alias{has_plan_product}
\title{Check if Customer is Subscribed to a Specific Product}
\usage{
has_plan_product(email, secret_key, product_id)
}
\arguments{
\item{email}{A string representing the customer's email.}

\item{secret_key}{A string representing the Stripe secret key for authentication.}

\item{product_id}{A string representing the product ID to check against the customer's subscription.}
}
\value{
A logical value: TRUE if the customer is subscribed to the specified product, FALSE otherwise.
}
\description{
This function determines whether a customer, identified by their email, is subscribed to a specific product in Stripe.
}
\examples{
\dontrun{
  is_subscribed_to_product <- has_plan_product("customer@example.com", "your_secret_key", "prod_example")
  print(is_subscribed_to_product)
}

}
