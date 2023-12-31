% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stripe_functions.R
\name{has_plan_price}
\alias{has_plan_price}
\title{Check if Customer is Subscribed with a Specific Price ID}
\usage{
has_plan_price(email, secret_key, price_id)
}
\arguments{
\item{email}{A string representing the customer's email.}

\item{secret_key}{A string representing the Stripe secret key for authentication.}

\item{price_id}{A string representing the price ID to check against the customer's subscription.}
}
\value{
A logical value: TRUE if the customer is subscribed with the specified price ID, FALSE otherwise.
}
\description{
This function checks whether a customer, identified by their email, is subscribed with a specific price ID in Stripe.
}
\examples{
\dontrun{
  is_subscribed_to_price <- has_plan_price("customer@example.com", "your_secret_key", "price_example")
  print(is_subscribed_to_price)
}

}
