% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stripe_functions.R
\name{plans_table}
\alias{plans_table}
\title{Retrieve and Format Stripe Plans Data}
\usage{
plans_table(secret_key)
}
\arguments{
\item{secret_key}{A string representing the Stripe secret key for authentication.}
}
\value{
A data frame containing Stripe plans data.
Each row represents a plan with fields like amount, currency, price_id, product_id, and period.
Returns NULL if no data is found or in case of an error.
}
\description{
This function fetches plans data from Stripe using the \code{make_api_request} helper function and formats it into a data frame.
It provides a structured view of the plans available in Stripe.
}
\examples{
\dontrun{
  plans <- plans_table("your_secret_key")
  print(plans)
}

}
