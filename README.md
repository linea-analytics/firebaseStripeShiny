# Saas with Shiny, Firebase, and Stripe
 
![thumbnail](https://raw.githubusercontent.com/linea-analytics/public/main/img/firebaseStripeShiny.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Lifecycle:Alpha](https://img.shields.io/badge/Lifecycle-Alpha-7e7E00)](https://r-pkg.org/pkg/linea)

This repo shows how to implement a subscription service (SaaS) with R **Shiny**, **Firebase**, and **Stripe**, using the R library `firebaseStripeShiny`.

### Pre-requisites:
- Familiarity with [R](https://www.r-project.org/) & [Shiny](https://shiny.posit.co/)
- Some familiarity with [APIs](https://www.w3schools.com/js/js_api_intro.asp) & [HTTP](https://www.w3schools.com/whatis/whatis_http.asp)

### Recommendations
- If you are unfamiliar with Firebase, I would suggest trying to use it, without Stripe, to get use to how it works. You can find the necessary information [here](https://firebase.john-coene.com/).

- The same goes for APIs and the `httr` package, which allows R to handle HTTP requests. You can learn about `httr` [here](https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html). 

---

### Installation
You can install firebaseStripeShiny with the following function from `devtools`:
```
devtools::install_github("linea-analytics/firebaseStripeShiny")
```

---

### How does this work?
If you have an R Shiny app that you would like to sell as a service to customers, you can do so using Firebase and Stripe.
- [Firebase](https://firebase.google.com/) is a service (owned by Google) that helps manage **user authentication**.
    - Luckily, there is an existing R package that simplifies using Firebase in shiny. The package can be found [here](https://firebase.john-coene.com/).
- [Stripe](https://stripe.com/gb) is a payment process platform that can help manage **subscriptions**.
    - Stripe provides pre-built interfaces for managing payments as well as an API which is relatively easy to use.

The `R/stripe_functions.R` file contains simple functions that leverage the Stripe API to compare your Firebase users to the list of those who paid for a subscription (your Stripe customers).

For this implementation, some functions assumes there are two subscriptions (e.g. monthly, yearly) but the same approach should work for any number of products.

---

### What do I use this?
The `inst/examples/app.R` file contains a basic Shiny app with:
- [Firebase](https://firebase.google.com/) sign-in & sign-out (user accounts)
- [Stripe](https://stripe.com/gb) sing-up to plan & manage current plan (subscriptions)
- Conditional content 
    - Shown based on whether the user is signed in and has purchased a subscription.

The only edits needed for this to work are the identifying informations for the Firebase and Stripe APIs. Once you filled the lines below, found in the example app below: 

```r
# FIREBASE ----
# for help on this: https://firebase.john-coene.com/guide/get-started/
Sys.setenv(FIREBASE_API_KEY = "xxx")
Sys.setenv(FIREBASE_PROJECT_ID = "xxx")
Sys.setenv(FIREBASE_AUTH_DOMAIN = "xxx")
Sys.setenv(FIREBASE_APP_ID = "xxx")
Sys.setenv(FIREBASE_STORAGE_BUCKET = "xxx")

tos_url = 'www.your_tos_page.com'
privacy_url = 'www.your_privacy_policy_page.com'


# STRIPE ----
# for help on this: https://stripe.com/docs/keys
Sys.setenv(STRIPE_SECRET_KEY = "xxx")
secret_key = Sys.getenv("STRIPE_SECRET_KEY")

# for help on this: https://stripe.com/docs/payments/checkout
purchase_plan_1_url = 'https://buy.stripe.com/xxxx'
purchase_plan_2_url = 'https://buy.stripe.com/xxxx'

price_id_1 = "xxx"
price_id_2 = "xxx"

# for help on this: https://stripe.com/docs/no-code/customer-portal
manage_plan_url = 'https://billing.stripe.com/p/login/xxxx'

# other options (optional)
info_email = 'xxx@xxx.xxx'

```
